extends CharacterBody3D
var target
var navigationAgent: NavigationAgent3D
var speed = 200
var health_bar
var health = 5
var direction = Vector3.RIGHT
var newPosition
var combat_controller
var turn_to_play = false
var is_reaching_target = false
var look_direction
var position_before_move
var newVelocity
var fall
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mass =4 
var is_in_combat = false
var player
var can_take_damage = false
@export var has_key = false

func _ready():
	navigationAgent = get_node("NavigationAgent3D")
	health_bar = $HealthBar
	combat_controller = $"../CombatController"
	combat_controller.combat_mode.connect(start_combat)
	player = $"../player"
	player.interact.connect(get_attacked)
	
func _physics_process(delta):
	if turn_to_play and is_in_combat:
		
		if is_reaching_target:
			if navigationAgent.is_navigation_finished():
				print(navigationAgent.distance_to_target())
				
			look_direction = navigationAgent.target_position
			look_direction.y = global_position.y
			look_at(look_direction)
			
			var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
			
			if (is_reaching_target and navigationAgent.distance_to_target() <= 3):
				set_target(global_position)
				newVelocity = Vector3.ZERO
				is_reaching_target = false
				try_attack(target.global_position)
			elif (global_position.distance_squared_to(position_before_move) >= 16):
				set_target(global_position)
				newVelocity = Vector3.ZERO
				is_reaching_target = false
				turn_to_play = false
				#print("enemy walked. next turn...")
				combat_controller.next_turn()
			else:
				newVelocity = (nextPathPosition - global_position).normalized() * speed * delta
			
			if(navigationAgent.avoidance_enabled):
				navigationAgent.set_velocity(newVelocity)
			else:
				_on_navigation_agent_3d_velocity_computed(newVelocity)
		else:
			try_attack(target.global_position)
	
	#if(is_on_floor()):
		#fall=0
	#else:
		#fall += -gravity * delta
	#velocity.y = fall*mass
			
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()
	
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				player.try_attack(global_position)
				#print("enemy cliked")
				can_take_damage = true
				
func ShowBubble():
	var tween = create_tween()
	tween.tween_property($bubble,"visible",true,0.1)
	$bubble.DisplayEmote("Surprise")
	tween.tween_property($bubble,"visible",false,3)

func choose(array):
	array.shuffle()
	return array.front()


func _on_timer_timeout():
	$Timer.wait_time = choose([0.5,1,1.5])
	
func start_combat():
	if !visible:
		return
	#print(self.name, " is starting combat")
	if is_in_combat:
		stop_combat()
		return
	await create_tween().tween_interval(1).finished
	health_bar.visible= true
	is_in_combat = true
	if target == null:
		target = combat_controller.get_target("ally")

func try_attack(_position : Vector3):
	#print("enemy try attacking target")
	target = combat_controller.target_validity(target,"ally")
	#print("target is : ",target)
	if(global_position.distance_squared_to(_position) > 9):
		set_target(_position)
		is_reaching_target = true
		#print("target too far")
		#print("enemy is reaching target")
	else:
		look_direction = _position
		look_direction.y = global_position.y
		look_at(look_direction)
		start_attack()
	
func set_target(_position : Vector3):
		navigationAgent.target_position = _position
		
		position_before_move = global_position
		
func start_attack():
	turn_to_play = false
	#print("attacking target")
	await create_tween().tween_interval(1).finished
	var health_left = target.take_damage(1)
	#print("target health left : ", health_left)
	if health_left == 0:
		target = combat_controller.get_target("ally")
	combat_controller.next_turn()
		
func take_damage(strength : float):
	if !is_in_combat:
		#print("enemy can't take damage")
		return 0
		
	#print("enemy damage amount : ", strength)
	health -= strength
	
	if health<=0:
		#print("enemy sending signal")
		disapear()
	
	health_bar.set_health(health*2)
	can_take_damage =false
	#print("enemy health left : ",health)
	return health
	
func disapear():
	position_before_move = global_position
	global_position.y = -10
	combat_controller.remove_opponent(self)
	if has_key:
		$"../Items/key".global_position = position_before_move
	
func stop_combat():
	#print("enemy : stopping combat")
	turn_to_play = false
	is_in_combat = false
	can_take_damage = false
	if health == 10:
		health_bar.visible = false

func get_attacked(_strength : float):
	if !can_take_damage:
		return
	print(self.name," is taking damage")
	take_damage(_strength)
	
