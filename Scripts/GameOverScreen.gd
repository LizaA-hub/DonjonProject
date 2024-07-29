extends PanelContainer


func _on_replay_button_button_down():
	%AudioManager.play("DefaultUI")
	get_tree().reload_current_scene()


func _on_leave_button_button_down():
	%AudioManager.play("DefaultUI")
	get_tree().quit()
