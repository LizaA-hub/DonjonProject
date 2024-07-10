extends Node3D

var message : String
	
func show_popup(_position : Vector3)->void:
	_position.y +=2
	global_position = _position
	$AnimationPlayer.play("PopUp")

func set_message(new_message : String) -> void :
	message = new_message
	$Sprite3D/SubViewport/Label.text = message


func _on_animation_player_animation_finished(_anim_name):
	$Sprite3D.scale = Vector3.ZERO
