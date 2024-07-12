extends EnvironmentAsset
var player 
var can_open
var is_empty = false
var camera
var pop_up

func _ready():
	player = %player
	player.interact.connect(open)
	
	camera = %MainCamera
	pop_up = %PopUp
	
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				if is_empty:
					return
					
				can_open = true
				player.try_interact(global_position)

func open(_value):
	if can_open:
		can_open = false
	else:
		return
		
	is_empty = true
	player.interact.disconnect(open)
	#print("player is opening the chest")
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var camera_rotation = camera.rotation

	camera.is_in_cinematic = true
	tween.tween_callback(Input.set_mouse_mode.bind(Input.MOUSE_MODE_CAPTURED))
	tween.tween_callback($AnimationPlayer.play.bind("chest_opening"))
	tween.tween_callback(player.unlock_weapon)
	tween.tween_property(camera, "position", player.global_position + Vector3(5,4,0),0.5)
	tween2.tween_property(camera, "rotation_degrees", Vector3(-30,90,0),0.5)
	tween.tween_callback(player.custom_look_at.bind(camera.global_position))
	tween.tween_callback(pop_up.show_popup.bind(player.global_position,"You found a stick!"))
	tween.tween_interval(2)
	tween.tween_callback(camera.reset_position.bind(camera_rotation,0.5))
	tween.tween_callback(Input.set_mouse_mode.bind(Input.MOUSE_MODE_VISIBLE))


