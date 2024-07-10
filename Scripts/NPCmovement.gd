class_name DefaultNPC

extends Character

#movement variable
var MaxDistance : float
enum{IDLE,NEW_DIR,MOVE}
var startPosition
var currentState = IDLE
var timer
var isPlayerNear = false
var PlayerBody
var lookDirection
var smooth = 5
var isFollowingPlayer = false

#health variable
var health_bar_display
var health_bar_timer

#region GodotFunctions

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
				end_turn()
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
			look_at(PlayerBody.global_position)
		else:
			match currentState:
				IDLE:
					pass
				NEW_DIR:
					direction = choose([Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK])
					#_on_timer_timeout()
				MOVE:
					newPosition = global_position + direction * speed * delta
					
					if(startPosition.distance_squared_to(newPosition) > MaxDistance):
						_on_move_timer_timeout()
						#print("new position ", newPosition, " too far away")
						return
				
					velocity = direction * speed * delta
					look_at(global_position+velocity)
					move_and_slide()

func _on_move_timer_timeout():
	timer.wait_time = choose([0.5,1,1.5])
	currentState = choose([IDLE,NEW_DIR,MOVE])
	#print("timer out, new state: ", currentState)

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
		
#endregion

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

	if target == null:
		target = combat_controller.get_target("enemy")
		
func try_attack(_position : Vector3):

	if(global_position.distance_squared_to(_position) > 81):
		set_target(_position)
		is_reaching_target = true
	else:
		custom_look_at(_position)
		start_attack()

func start_attack():
	var strength = 1
	turn_to_play = false
	play_animation()
	await create_tween().tween_interval(1).finished
	if energy >=5:
		strength = [1,5].pick_random()
	var health_left = target.take_damage(strength)
	energy -= strength
	energy_changed.emit(energy)
	if health_left <= 0:
		target = combat_controller.get_target("enemy")

	end_turn()
	
func disapear():
	position_before_move = global_position
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
func play_animation():
	pass

func set_turn():
	target = combat_controller.target_validity(target,"enemy")
	$TurnIndicator.visible = true
	if target != null:
		turn_to_play = true
	else:
		print(self.name, " can't set target")
		
func end_turn():
	#print("NPC: end turn")
	if turn_to_play:
		turn_to_play = false
	combat_controller.next_turn()
	$TurnIndicator.visible = false

func stop_combat():
	#print("enemy : stopping combat")
	turn_to_play = false
	is_in_combat = false
	can_take_damage = false
	$TurnIndicator.visible = false
	isFollowingPlayer = true

func take_potion(potion_type: String, amount : int):
	if potion_type == "health":
		health += amount
		if health>10:
			health = 10 
		health_bar.set_health(health)
		health_changed.emit(health)
		
	if potion_type == "energy":
		energy += amount
		if energy>10:
			energy = 10 
		health_bar.set_energy(energy)
		energy_changed.emit(energy)
	
	else:
		print(self.namme, " can't take potion of type : ", potion_type)

func on_left_click():
	PlayerBody.open_interaction_panel(true,self)
