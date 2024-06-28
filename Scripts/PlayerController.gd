extends Character

#movement variable
var Direction = Vector3.ZERO
var lookDirection
var traveled_distance = 0
var is_moving = false

#interaction variable
signal interact(strengh:float)
var has_weapon = false
enum InteractableType {ATTACKABLE,INTERACTABLE}
var target_type : InteractableType
var can_open_door = false

#region GodotFunctions
func _ready():
	var ground = $"../../NavigationRegion3D"
	ground.mouse_clicked.connect(_init_move)
	combat_controller = $"../../CombatController"
	combat_controller.combat_mode.connect(start_combat)

	health_bar = $SubViewport/Control
	health = max_health
	health_bar.initialize(pseudo,max_health,health_changed)


func _physics_process(delta):

	if navigationAgent.is_navigation_finished():
		return

	custom_look_at(navigationAgent.target_position)
	var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
	
	if is_in_combat:
		traveled_distance +=  global_position.distance_squared_to(position_before_move) 
		if traveled_distance >= 16:
			set_target(global_position)
			newVelocity = Vector3.ZERO
			is_reaching_target = false
			end_turn()
	
	if (is_reaching_target and navigationAgent.distance_to_target() <= 3):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
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
		set_target(_position)
	else:
		if is_moving or !turn_to_play:
			return
		set_target(_position)
		is_moving = true
		position_before_move = global_position

#region CombatFunctions
func move_weapon():
	$AnimationPlayer.play("Weapon")
		
func try_attack(_position : Vector3):
	if is_in_combat and !turn_to_play:
		return
		
	if(global_position.distance_squared_to(_position) > 9):
		_init_move(_position)
		is_reaching_target = true
		target_type = InteractableType.ATTACKABLE
	else:
		custom_look_at(_position)
		start_attack()
		
func start_attack():
	if has_weapon:
		move_weapon()
		interact.emit(1)
	if is_in_combat:
		end_turn()
		
func unlock_weapon():
	$Weapon.visible = true
	has_weapon = true
	
func start_combat():
	if is_in_combat:
		stop_combat()
		return
		
	set_target(global_position)
	newVelocity = Vector3.ZERO
	traveled_distance = 0
	
	if(navigationAgent.avoidance_enabled):
		navigationAgent.set_velocity(newVelocity)
	else:
		_on_navigation_agent_3d_velocity_computed(newVelocity)
		
	is_in_combat = true
	
func disapear():#game over
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
func end_turn():
	is_moving = false
	turn_to_play = false
	traveled_distance = 0
	$TurnIndicator.visible = false
	combat_controller.next_turn()

func set_turn():
	turn_to_play = true
	$TurnIndicator.visible = true
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
	
func pick_up_key():
	can_open_door = true

func door_opening(door : Vector3):
	is_in_combat = true
	var ally = %prisoner
	custom_look_at(ally.global_position)
	await create_tween().tween_interval(1).finished
	custom_look_at(door)
	await create_tween().tween_interval(1).finished
	is_in_combat = false

func heal(amount : float):
	health += amount
	if health>10:
		health = 10 
	health_bar.set_health(health)

