extends Node3D

var pop_up
var player
@onready var meshes = [$ExternHallo,$InternHallo]
var camera
var ally
var menu

func initialize(_pop_up,_player,_camera,_ally, _menu) -> void:
	pop_up = _pop_up
	player = _player
	camera = _camera
	ally = _ally
	menu = _menu
	
func _toggle_visibility( _on : bool):
	print("hallo area : visibility toggled")
	for mesh in meshes:
		if _on:
			mesh.set_layer_mask_value(3,true)
			mesh.set_layer_mask_value(2,false)
		else:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(2,true)


func _on_body_entered(body):
	if body.name == "player":
		print("end area triggered")
		var tween = get_tree().create_tween()
		var camera_rotation = camera.rotation
		
		camera.is_in_cinematic = true
		tween.tween_callback(Input.set_mouse_mode.bind(Input.MOUSE_MODE_CAPTURED))
		tween.tween_property(camera, "position", player.global_position + Vector3(5,4,0),0.5)
		tween.parallel().tween_property(camera, "rotation_degrees", Vector3(-30,90,0),0.5)
		tween.tween_callback(player.custom_look_at.bind(camera.global_position))
		tween.tween_callback(pop_up.show_popup.bind(player.global_position, "Finish !"))
		tween.tween_callback(player.ShowBubble.bind("Happy", 1.5))
		tween.tween_callback(ally.ShowBubble.bind("Happy", 1.5))
		tween.tween_interval(2)
		tween.tween_callback(menu.end_screen)
		tween.tween_callback(Input.set_mouse_mode.bind(Input.MOUSE_MODE_VISIBLE))
		tween.tween_interval(1)
		tween.tween_callback(camera.reset_position.bind(camera_rotation,0.5))
		
		$".".body_entered.disconnect(_on_body_entered)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				player._init_move(global_position)
