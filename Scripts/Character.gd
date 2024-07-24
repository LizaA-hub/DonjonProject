class_name Character

extends CharacterBody3D

#movement variable
var target
@onready var navigationAgent = get_node("NavigationAgent3D")
@export var speed : float = 200
var direction = Vector3.RIGHT
var newPosition
var is_reaching_target = false
var look_direction
var position_before_move
var newVelocity
var fall = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mass =4 
var right_click_pressed = false
var ground


#health and energy variable
var health_bar
@export var max_health : int = 5
var health
@export var max_energy : int = 10
var energy
signal health_changed(float)
signal energy_changed(float)
var refill_timer = 0

#combat variable
var combat_controller
var turn_to_play = false
var is_in_combat = false
var can_take_damage = false
@onready var pop_up_prefab = preload("res://Nodes/DamagePopUp.tscn")

@export var pseudo : String
@export var viewport : SubViewport

#region GodotFunction
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()
	
func set_right_click(on : bool) -> void :
	right_click_pressed = on

func _on_mouse_entered():
	if right_click_pressed:
		return
	$Sprite3D.visible= true

func _on_mouse_exited():
	
	$Sprite3D.visible= false



#func _process(delta):
	#if is_in_combat:
		#return
		#
	#if energy < max_energy:
		#if refill_timer < 1:
			#refill_timer += delta
		#else:
			#refill_energy()
			#refill_timer = 0
#endregion
				
func ShowBubble(emote : String, duration : float = 0):
	var tween = create_tween()
	tween.tween_property($bubble,"visible",true,0.1)
	$bubble.DisplayEmote(emote)
	
	if duration >0:
		tween.tween_property($bubble,"visible",false,duration)

func choose(array):
	array.shuffle()
	return array.front()
	
func set_target(_position : Vector3):
		navigationAgent.target_position = _position
		position_before_move = global_position
		
func take_damage(strength : float):

	if !is_in_combat:
		return 0
	health -= strength
	show_damage(-1*strength)
	
	if health<=0:
		disapear()
	else:
		$AnimationPlayer.play("TakeDamage")
	
	health_changed.emit(health)
	can_take_damage =false
	return health
	
func disapear():
	pass
	
func stop_combat():
	if !is_in_combat:
		return
	#print("enemy : stopping combat")
	turn_to_play = false
	is_in_combat = false
	can_take_damage = false
	$TurnIndicator.visible = false
	
func custom_look_at(_position : Vector3):
	if _position == global_position:
		return
	look_direction = _position
	look_direction.y = global_position.y
	look_at(look_direction)
	
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				on_left_click()

func on_left_click():
	pass
	
func refill_energy():
	if energy != max_energy:
		energy+=1
		energy_changed.emit(energy)

func show_damage(amount : float)-> void:
	var label
	if amount >= 0:
		label = "+ " + String.num(amount)
	else :
		label = "- " + String.num(amount*-1)
		
	var pop_up = pop_up_prefab.instantiate()
	pop_up.set_label(label)
	add_child(pop_up)
