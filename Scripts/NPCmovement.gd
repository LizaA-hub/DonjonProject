class_name DefaultNPC

extends CharacterBody3D

var MaxDistance : float
var speed = 100.0  # movement speed
enum{IDLE,NEW_DIR,MOVE}
var startPosition
var currentState = IDLE
var direction = Vector3.RIGHT
var newPosition
var timer
var isPlayerNear = false
var PlayerBody
var lookDirection
var smooth = 5
@onready var navigationAgent: NavigationAgent3D = get_node("NavigationAgent3D")
var isFollowingPlayer = false
var is_in_combat = false
var health_bar
var target
var combat_controller
var turn_to_play = false
#var can_take_damage = false
var health = 10
var is_reaching_target = false
var position_before_move
var newVelocity

func _ready():
	randomize()
	startPosition = position


func _physics_process(delta):
	if(isFollowingPlayer):
		navigationAgent.target_position = PlayerBody.global_position
		
		if navigationAgent.is_navigation_finished():
			return
		
		var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
		var currentAgenPosition: Vector3 = global_position
		newVelocity = (nextPathPosition - currentAgenPosition).normalized() * speed * delta
		
		custom_look_at(PlayerBody.global_position)
		if(navigationAgent.avoidance_enabled):
			navigationAgent.set_velocity(newVelocity)
		else:
			_on_navigation_agent_3d_velocity_computed(newVelocity)
			
	elif turn_to_play and is_in_combat:
		
		if is_reaching_target:
			if navigationAgent.is_navigation_finished():
				print(navigationAgent.distance_to_target())
				
			custom_look_at(navigationAgent.target_position)
			
			var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
			
			if (is_reaching_target and navigationAgent.distance_to_target() <= 9):
				set_target(global_position)
				newVelocity = Vector3.ZERO
				is_reaching_target = false
				try_attack(target.global_position)
			elif (global_position.distance_squared_to(position_before_move) >= 16):
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
		else:
			try_attack(target.global_position)
			
	elif !isFollowingPlayer and !is_in_combat:
		if(isPlayerNear):
			#lookDirection = lerp(basis.z, PlayerBody.position, delta*smooth)
			look_at(PlayerBody.global_position)
			#if(Input.is_key_pressed(KEY_SPACE)):
				#isFollowingPlayer = true
				#ShowBubble()
		else:
			match currentState:
				IDLE:
					pass
				NEW_DIR:
					direction = choose([Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK])
					#_on_timer_timeout()
				MOVE:
					newPosition = position + direction * speed * delta
					
					if(abs(newPosition.x) > MaxDistance or abs(newPosition.z) > MaxDistance):
						_on_timer_timeout()
						#print(newPosition)
						return
				
					velocity = direction * speed * delta
					look_at(global_position+velocity)
					move_and_slide()

func choose(array):
	array.shuffle()
	return array.front()

func _on_timer_timeout():
	timer.wait_time = choose([0.5,1,1.5])
	currentState = choose([IDLE,NEW_DIR,MOVE])

func _on_area_3d_body_entered(body):
	if(body.name == "player"):
		isPlayerNear = true
		if (PlayerBody == null):
			PlayerBody = body
		timer.set_paused(true)
	


func _on_area_3d_body_exited(body):
	if(body.name == "player"):
		isPlayerNear = false
		timer.set_paused(false)



func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()
	
func ShowBubble(emote : String, duration : float = 0):
	var tween = create_tween()
	tween.tween_property($bubble,"visible",true,0.1)
	$bubble.DisplayEmote(emote)
	
	if duration >0:
		tween.tween_property($bubble,"visible",false,duration)

func start_combat():
	combat_controller.add_opponent(self)
	if is_in_combat:
		stop_combat()
		return
	isFollowingPlayer = false
	is_in_combat = true
	set_target(global_position)
	
	newVelocity = Vector3.ZERO
	if(navigationAgent.avoidance_enabled):
			navigationAgent.set_velocity(newVelocity)
	else:
		_on_navigation_agent_3d_velocity_computed(newVelocity)
	
	await create_tween().tween_interval(1).finished
	health_bar.visible= true
	if target == null:
		target = combat_controller.get_target("enemy")
	
func stop_combat():
	turn_to_play = false
	is_in_combat = false
	isFollowingPlayer = true
	if health == 10:
		health_bar.visible = false
	
func custom_look_at(_position : Vector3):
	var look_direction = _position
	look_direction.y = global_position.y
	look_at(look_direction)
	
func set_target(_position : Vector3):
		navigationAgent.target_position = _position
		
		position_before_move = global_position
		
func try_attack(_position : Vector3):

	if(global_position.distance_squared_to(_position) > 81):
		set_target(_position)
		is_reaching_target = true
	else:
		custom_look_at(_position)
		start_attack()

func start_attack():
	turn_to_play = false
	play_animation()
	await create_tween().tween_interval(1).finished
	var health_left = target.take_damage(1)
	if health_left <= 0:
		target = combat_controller.get_target("enemy")
		#if target != null:
			#print("new target is: ", target.name)
	combat_controller.next_turn()
	
func take_damage(strength : float):
	if !is_in_combat:
		return 0
		
	health -= strength
	
	if health<=0:
		disapear()
	
	health_bar.set_health(health)
	return health
	
func disapear():
	position_before_move = global_position
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
func play_animation():
	pass

func set_turn():
	target = combat_controller.target_validity(target,"enemy")
	if target != null:
		turn_to_play = true
	else:
		print(self.name, " can't set target")
