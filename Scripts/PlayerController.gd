extends CharacterBody3D

var speed = 400 # movement speed$
var Direction = Vector3.ZERO
var lookDirection
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall :float
var mass =4 
@onready var navigationAgent: NavigationAgent3D = get_node("NavigationAgent3D")
signal interact(strengh:float)
var has_weapon = false
var is_reaching_target = false
var newVelocity
enum InteractableType {ATTACKABLE,INTERACTABLE}
var target_type : InteractableType
var is_in_combat = false
var combat_controller
var health = 10
var health_bar
var turn_to_play = false
var position_before_move
var can_open_door = false


func _ready():
	var ground = get_node("../NavigationRegion3D")
	ground.mouse_clicked.connect(set_target)
	combat_controller = $"../CombatController"
	combat_controller.combat_mode.connect(start_combat)
	health_bar = $HealthBar

func _physics_process(delta):

	if navigationAgent.is_navigation_finished():
		return

	custom_look_at(navigationAgent.target_position)
	var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
	
	if (is_reaching_target and navigationAgent.distance_to_target() <= 3):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		start_interact()
	elif (turn_to_play and global_position.distance_squared_to(position_before_move) >= 16):
		set_target(global_position)
		newVelocity = Vector3.ZERO
		is_reaching_target = false
		turn_to_play = false
		combat_controller.next_turn()
	else:
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
		

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()

	
func set_target(_position : Vector3):
	#print("setting new target position")
	#print("is in combat : ", is_in_combat)
	#print("turn_to_play : ", turn_to_play)
	if !is_in_combat or turn_to_play:
		navigationAgent.target_position = _position
		position_before_move = global_position

func move_weapon():
	#if $AnimationPlayer.is_playing:
		#$AnimationPlayer.stop()
	$AnimationPlayer.play("Weapon")
		
func try_attack(_position : Vector3):
	if is_in_combat and !turn_to_play:
		return
		
	if(global_position.distance_squared_to(_position) > 9):
		set_target(_position)
		is_reaching_target = true
		target_type = InteractableType.ATTACKABLE
	else:
		custom_look_at(_position)
		start_attack()
		
func start_attack():
	#print("player is attacking")
	if has_weapon:
		move_weapon()
		interact.emit(1)
	if is_in_combat:
		turn_to_play = false
		combat_controller.next_turn()
		
func try_interact(_position : Vector3):
	if(global_position.distance_squared_to(_position) > 4):
		set_target(_position)
		is_reaching_target = true
		target_type = InteractableType.INTERACTABLE
	else:
		custom_look_at(_position)
		start_interact()
		
	
func start_interact():
	#print(target_type)
	match(target_type):
		InteractableType.ATTACKABLE:
			start_attack()
		InteractableType.INTERACTABLE:
			interact.emit(0)

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
	await create_tween().tween_interval(1).finished
	health_bar.visible = true
	
func stop_combat():
	#print("player : stoping combat")
	is_in_combat = false
	turn_to_play = false
	if health == 10:
		health_bar.visible = false
		
func take_damage(_amount : float):
	health -= _amount
	if health<=0:
		disapear()
	health_bar.set_health(health)
	return health
	
func disapear():#game over
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
func pick_up_key():
	can_open_door = true

func door_opening(door : Vector3):
	is_in_combat = true
	var ally = $"../prisoner"
	custom_look_at(ally.global_position)
	await create_tween().tween_interval(1).finished
	custom_look_at(door)

func end_opening():
	is_in_combat = false
	
func custom_look_at(_position : Vector3):
	var look_direction = _position
	look_direction.y = global_position.y
	look_at(look_direction)
