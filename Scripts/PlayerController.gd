extends Character

#movement variable
var Direction = Vector3.ZERO
var lookDirection
var travel_distance_left = 4
var is_moving = false

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
	ground.combat_started.connect(start_combat)
	ground.right_click.connect(set_right_click)
	combat_controller = $"../../CombatController"
	combat_controller.combat_stopped.connect(stop_combat)
	combat_controller.combat_started.connect(show_combat_path)
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
	
	if is_in_combat and (global_position.distance_squared_to(position_before_move) >= 25):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		end_turn()
		
	if (is_reaching_target and can_attack(navigationAgent.target_position)):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		is_moving = false
		start_interact()
		
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
		if is_reaching_target:
			is_reaching_target = false
		set_target(_position)
		#close_interaction_panel()
	else:
		if is_moving or !turn_to_play:
			return
		if is_reaching_target:
			set_target(_position)
		else:
			set_target(combat_path.get_target_position())
		is_moving = true
		

#region CombatFunctions
func move_weapon(anim : String = "Weapon"):
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim)
		
func try_attack(_target, special_attack : bool = false) -> void:
	target = _target
	if is_in_combat and !turn_to_play:
		return
		
	var target_position = target.global_position
		
	if !can_attack(target_position):
		is_reaching_target = true
		set_target(target_position)
		target_type = InteractableType.ATTACKABLE
	else:
		custom_look_at(target_position)
		if special_attack:
			start_special_attack()
			return
			
		start_attack()
		
func start_attack():
	if !has_weapon:
		ShowBubble("Question", 2)
		return
		
	move_weapon()
		
	if is_in_combat:
		energy -= 1
		energy_changed.emit(energy)
		end_turn()
		
	target.take_damage(1)
		
func start_special_attack()-> void:
	if !has_weapon:
		return
		
	move_weapon("AttackSpe")
	await create_tween().tween_interval(.5).finished
	if is_in_combat:
		energy -= 5
		energy_changed.emit(energy)
		end_turn()
		
	target.take_damage(5)
		
func unlock_weapon():
	$body/Weapon.visible = true
	has_weapon = true
	
func start_combat(_opponents):
	is_in_combat = true
	set_target(global_position)
	
func show_combat_path() -> void:
	attack_zone.visible = true
	$CombatPath.visible = true
	$CombatPath.initialize(ground.mouse_hover, ground.mouse_not_on_ground, interaction_ui.mouse_on_panel)
	
func disapear():#game over
	$AnimationPlayer.play("disappear")
	combat_controller.game_over()
	
	
func end_turn():
	#print("player : end turn")
	is_moving = false
	turn_to_play = false
	$TurnIndicator.visible = false
	combat_controller.next_turn()
	player_turn.emit(false)
	

func set_turn():
	turn_to_play = true
	$TurnIndicator.visible = true
	player_turn.emit(true)
	if target != null and (target.is_in_group("ally") or target.is_in_group("enemy")):
		if target.health > 0:
			interaction_ui.set_buttons(get_target_type(target))
			
	position_before_move = global_position
	travel_distance_left = 4
#endregion
	
func try_interact(_target, _position = Vector3(-10,-10,-10)):
	target = _target
	var target_position
	if is_in_combat and !turn_to_play:
		return
	
	if _position != Vector3(-10,-10,-10):
		target_position = _position
	else:
		target_position = target.global_position
		
	if !can_attack(target_position):
		set_target(target_position)
		is_reaching_target = true
		target_type = InteractableType.INTERACTABLE
	else:
		custom_look_at(target_position)
		target_type = InteractableType.INTERACTABLE
		start_interact()
		
func start_interact():
	#print(target_type)
	match(target_type):
		InteractableType.ATTACKABLE:
			start_attack()
		InteractableType.INTERACTABLE:
			target.interact()
			if is_in_combat:
				end_turn()

func door_opening():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var ally = %prisoner
	custom_look_at(ally.global_position)
	await create_tween().tween_interval(1).finished
	custom_look_at(target.global_position)
	await create_tween().tween_interval(3).finished
	is_in_combat = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func take_potion(potion_type: String, amount : int):
	if potion_type == "health":
		health += amount
		if health>10:
			health = 10 
		health_bar.set_health(health)
		health_changed.emit(health)
		show_damage(amount)
		
	elif potion_type == "energy":
		energy += amount
		if energy>10:
			energy = 10 
		health_bar.set_energy(energy)
		energy_changed.emit(energy)
	
	else:
		print(self.name, " can't take potion of type : ", potion_type)
	
func stop_combat():
	if turn_to_play:
		end_turn()
	is_in_combat = false
	can_take_damage = false
	#close_interaction_panel()
	attack_zone.visible = false
	$CombatPath.deactivate(ground.mouse_hover, ground.mouse_not_on_ground,interaction_ui.mouse_on_panel)
	$CombatPath.visible = false
	
func open_interaction_panel(_open :bool, _target):
	if is_in_combat and !turn_to_play:
		return
	
	target = _target
	if !interaction_ui.set_target(target):
		interaction_ui.close_panel()
		return
	else:
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

	
func can_attack(_target : Vector3):
	if global_position.distance_squared_to(_target) > 9:
		return false
	else: return true
	
func can_move_attack(_target : Vector3):
	if global_position.distance_squared_to(_target) > 64:
		return false
	else: return true

func can_open_door() -> bool:
	return inventory.inventory_has(Item.types.KEY)

func remove_item(item : Item.types) -> void:
	inventory.remove(item)
