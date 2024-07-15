extends PanelContainer


func _on_replay_button_button_down():
	#print("replay button clicked")
	get_tree().reload_current_scene()


func _on_leave_button_button_down():
	#print("leave button clicked")
	get_tree().quit()
