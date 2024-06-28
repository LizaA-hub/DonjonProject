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
var fall
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mass =4 


#health variable
var health_bar
@export var max_health : int = 5
var health

#combat variable
var combat_controller
var turn_to_play = false
var is_in_combat = false
var can_take_damage = false

@export var pseudo : String
@export var viewport : SubViewport
signal health_changed(float)

#region GodotFunction
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()

func _on_mouse_entered():
	$Timer.stop()
	$Sprite3D.visible= true

func _on_mouse_exited():
	$Timer.start(.5)

func _on_timer_timeout():
	$Sprite3D.visible= false
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
	
	if health<=0:
		disapear()
	
	health_changed.emit(health)
	can_take_damage =false
	return health
	
func disapear():
	pass
	
func stop_combat():
	#print("enemy : stopping combat")
	turn_to_play = false
	is_in_combat = false
	can_take_damage = false
	$TurnIndicator.visible = false
	
func custom_look_at(_position : Vector3):
	look_direction = _position
	look_direction.y = global_position.y
	look_at(look_direction)

