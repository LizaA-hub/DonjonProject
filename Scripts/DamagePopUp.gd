extends Node3D

func set_label(message: String):
	$Damagedisplay/DamageViewport/Label.text = message
	
func _enter_tree():
	$AnimationPlayer.play("DamageDisplay")
	
func _on_animation_player_animation_finished(_anim_name):
	queue_free()
