extends Node3D

var message : String

func _ready():
	$Sprite3D.visible = false
	
func show_popup(_position : Vector3, _message: String)->void:
	message = _message
	_position.y +=2
	global_position = _position
	var tween = get_tree().create_tween()
	tween.tween_callback(set_message)
	tween.tween_callback($AnimationPlayer.play.bind("PopUp"))

func set_message() -> void :
	$Sprite3D/SubViewport/Label.text = message


func _on_animation_player_animation_finished(_anim_name):
	$Sprite3D.scale = Vector3.ZERO
