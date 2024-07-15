extends Control

var open = false
var mouse_over = false

func _on_menu_button_button_down():
	toggle_menu()

func toggle_menu() -> void:
	open = !open
	$VBoxContainer.visible = open
	
func _on_replay_button_button_down():
	replay_game()
	
func replay_game()-> void:
	get_tree().reload_current_scene()
	
func _on_leave_button_button_down():
	leave_game()
	
func leave_game() -> void : 
	get_tree().quit()


func _on_v_box_container_mouse_entered():
	mouse_over = true


func _on_v_box_container_mouse_exited():
	mouse_over = false
	
func _input(event):
	if !open:
		return
	if event is InputEventMouseButton:
		if event.pressed and !mouse_over:
			toggle_menu()
