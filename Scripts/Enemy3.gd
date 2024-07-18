extends Character

var player
@export var has_key = false
@export var has_potion = false
var alive : bool = true

#region GodotFunctions
func _ready():
	health_bar = $SubViewport/Control
	health = max_health
	energy = max_energy
	health_bar.initialize(pseudo,max_health,health_changed,max_energy,energy_changed)
	
	combat_controller =%CombatController
	combat_controller.combat_stopped.connect(stop_combat)
	combat_controller.combat_started.connect(start_combat)
	player = %player
	player.interact.connect(get_attacked)
	
	ground = $"../../NavigationRegion3D"
	ground.right_click.connect(set_right_click)

	
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
				end_turn()
				
			else:
				newVelocity = (nextPathPosition - global_position).normalized() * speed * delta
			
			if(navigationAgent.avoidance_enabled):
				navigationAgent.set_velocity(newVelocity)
			else:
				_on_navigation_agent_3d_velocity_computed(newVelocity)
		else:
			try_attack(target.global_position)
			
	move_and_slide()
	
func on_left_click():
	can_take_damage = true
	player.open_interaction_panel(true,self)

#endregion
	
func start_combat():
	if !alive or !visible:
		#print(name," : is not alive")
		return

	if is_in_combat:
		stop_combat()
		return
	#print(name," : ",global_position)
	is_in_combat = true
	remove_from_group("dynamic")
	if target == null:
		target = combat_controller.get_target("ally")

func try_attack(_position : Vector3):

	if(global_position.distance_squared_to(_position) > 9):
		set_target(_position)
		is_reaching_target = true

	else:
		look_direction = _position
		look_direction.y = global_position.y
		look_at(look_direction)
		start_attack()
		
func start_attack():
	var strength = 1
	turn_to_play = false

	await create_tween().tween_interval(0.5).finished
	$AnimationPlayer.play("enemy_attack")
	await create_tween().tween_interval(0.6).finished
	$AnimationPlayer.stop()
	if energy >=5 :
		strength = [1,5].pick_random()
	var health_left = target.take_damage(strength)
	
	energy -= strength
	energy_changed.emit(energy)

	if health_left <= 0:
		target = combat_controller.get_target("ally")
		
	end_turn()
	
func disapear():
	#print(name, " : disapearring")
	position_before_move = global_position
	global_position.y = -10
	combat_controller.remove_opponent(self)
	
	%InteractionUI.target_died(self)
	
	if has_key:
		%key.global_position = position_before_move
	if has_potion:
		%potion.global_position = position_before_move
	alive = false

func get_attacked(_strength : float):
	if !can_take_damage:
		return

	take_damage(_strength)
	
func set_turn():
	if !is_in_combat:
		return
		
	target = combat_controller.target_validity(target,"ally")
	$TurnIndicator.visible = true
	if target != null:
		await create_tween().tween_interval(0.6).finished
		turn_to_play = true
	else:
		print(self.name, " can't set target")
		
func end_turn():
	#print(name," : end turn")
	if turn_to_play:
		turn_to_play = false
	$TurnIndicator.visible = false
	combat_controller.next_turn()
