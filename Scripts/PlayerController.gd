extends Character

#movement variable
var Direction = Vector3.ZERO
var lookDirection
var travel_distance_left = 4
var is_moving = false
var ground

#interaction variable
signal interact(strengh:float)
var has_weapon = false
enum InteractableType {ATTACKABLE,INTERACTABLE}
var target_type : InteractableType
var interaction_ui
var inventory

#combatvariable
signal player_turn(bool)
var attack_zone
var combat_path

#region GodotFunctions
func _ready():
	ground = $"../../NavigationRegion3D"
	ground.mouse_clicked.connect(_init_move)
	combat_controller = $"../../CombatController"
	combat_controller.combat_stopped.connect(stop_combat)
	attack_zone = $AttackZone
	combat_path = $CombatPath

	health_bar = $SubViewport/Control
	health = max_health
	energy = max_energy
	health_bar.initialize(pseudo,max_health,health_changed,max_energy,energy_changed)
	
	interaction_ui = %InteractionUI
	inventory = %InventorySystem

func _physics_process(delta):

	if navigationAgent.is_navigation_finished() and !is_in_combat:
		return
	elif navigationAgent.is_navigation_finished() and is_in_combat and !is_moving:
		return

	custom_look_at(navigationAgent.target_position)
	var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
	
	if is_in_combat and navigationAgent.is_navigation_finished() and is_moving:
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_moving = false
		end_turn()
	
	if (is_reaching_target and can_attack(navigationAgent.target_position)):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		is_moving = false
		start_interact()
		
	if is_in_combat and (global_position.distance_squared_to(position_before_move) >= 25):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		end_turn()
	
	newVelocity = (nextPathPosition - global_position).normalized() * speed * delta
	
	if(navigationAgent.avoidance_enabled):
		navigationAgent.set_velocity(newVelocity)
	else:
		_on_navigation_agent_3d_velocity_computed(newVelocity)

	if(is_on_floor()):
		fall=0
	else:
		fall += -gravity * delta
	velocity.y = fall*mass
	
	move_and_slide()

#endregion

func _init_move(_position : Vector3):
	if !is_in_combat:
		set_target(_position)
		#if is_reaching_target:
			#is_reaching_target = false
		close_interaction_panel()
	else:
		if is_moving or !turn_to_play:
			return
		if is_reaching_target:
			set_target(_position)
		else:
			set_target(combat_path.get_target_position())
		is_moving = true
		

#region CombatFunctions
func move_weapon():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Weapon")
		
func try_attack(_target, special_attack : bool = false) -> void:
	if is_in_combat and !turn_to_play:
		return
		
	var target_position = _target.global_position
		
	if !can_attack(target_position):
		is_reaching_target = true
		_init_move(target_position)
		target_type = InteractableType.ATTACKABLE
	else:
		if special_attack:
			start_special_attack()
			return
			
		custom_look_at(target_position)
		start_attack()
		
func start_attack():
	if !has_weapon:
		return
		
	move_weapon()
		
	if is_in_combat:
		energy -= 1
		energy_changed.emit(energy)
		end_turn()
		
	interact.emit(1)
		
func start_special_attack()-> void:
	if !has_weapon:
		return
		
	move_weapon() #create another anim later
	if is_in_combat:
		energy -= 5
		energy_changed.emit(energy)
		end_turn()
		
	interact.emit(5)
		
func unlock_weapon():
	$Weapon.visible = true
	has_weapon = true
	
func start_combat():
	if is_in_combat:
		stop_combat()
		return
		
	set_target(global_position)
	newVelocity = Vector3.ZERO
	
	if(navigationAgent.avoidance_enabled):
		navigationAgent.set_velocity(newVelocity)
	else:
		_on_navigation_agent_3d_velocity_computed(newVelocity)
		
	is_in_combat = true
	
	attack_zone.visible = true
	$CombatPath.visible = true
	$CombatPath.initialize(ground.mouse_hover, ground.mouse_not_on_ground, interaction_ui.mouse_on_panel)
	
func disapear():#game over
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
func end_turn():
	#print("player : end turn")
	is_moving = false
	turn_to_play = false
	$TurnIndicator.visible = false
	combat_controller.next_turn()
	player_turn.emit(false)
	if target != null:
		if target.health <= 0:
			close_interaction_panel()
	

func set_turn():
	turn_to_play = true
	$TurnIndicator.visible = true
	player_turn.emit(true)
	if target != null:
		if target.health > 0:
			interaction_ui.set_buttons(get_target_type(target))
			
	position_before_move = global_position
	travel_distance_left = 4
#endregion
	
func try_interact(_position : Vector3):
	if(global_position.distance_squared_to(_position) > 9):
		set_target(_position)
		is_reaching_target = true
		target_type = InteractableType.INTERACTABLE
	else:
		custom_look_at(_position)
		target_type = InteractableType.INTERACTABLE
		start_interact()
		
func start_interact():
	#print(target_type)
	match(target_type):
		InteractableType.ATTACKABLE:
			start_attack()
		InteractableType.INTERACTABLE:
			interact.emit(0)
	if is_in_combat:
		end_turn()

func door_opening(door : Vector3):
	is_in_combat = true
	var ally = %prisoner
	custom_look_at(ally.global_position)
	await create_tween().tween_interval(1).finished
	custom_look_at(door)
	await create_tween().tween_interval(1).finished
	is_in_combat = false

func take_potion(potion_type: String, amount : int):
	if potion_type == "health":
		health += amount
		if health>10:
			health = 10 
		health_bar.set_health(health)
		health_changed.emit(health)
		
	elif potion_type == "energy":
		energy += amount
		if energy>10:
			energy = 10 
		health_bar.set_energy(energy)
		energy_changed.emit(energy)
	
	else:
		print(self.name, " can't take potion of type : ", potion_type)
	
func stop_combat():
	
	is_in_combat = false
	can_take_damage = false
	close_interaction_panel()
	attack_zone.visible = false
	$CombatPath.deactivate(ground.mouse_hover, ground.mouse_not_on_ground,interaction_ui.mouse_on_panel)
	$CombatPath.visible = false
	
func open_interaction_panel(open :bool, _target):
	if is_in_combat and !turn_to_play:
		return
	
	target = _target
	if !interaction_ui.set_target(target):
		close_interaction_panel()
	else:
		interaction_ui.visible = open
		interaction_ui.set_buttons(get_target_type(target))
	
		
func get_target_type(_target):
	if(_target.is_in_group("enemy")):
		return "enemy"
	elif(_target.is_in_group("ally")):
		return"ally"
	else:
		print("left click interaction : target group not recognized")
		return "ally"
	
func on_left_click():
	open_interaction_panel(true, self)

func close_interaction_panel():
	target = null
	interaction_ui.set_target(null)
	interaction_ui.visible = false
	inventory.toggle_inventory(false)
	
func can_attack(_target : Vector3):
	if global_position.distance_squared_to(_target) > 9:
		return false
	else: return true
	
func can_move_attack(_target : Vector3):
	if global_position.distance_squared_to(_target) > 25:
		return false
	else: return true

func can_open_door() -> bool:
	return inventory.inventory_has(Item.types.KEY)

func remove_item(item : Item.types) -> void:
	inventory.remove(item)
