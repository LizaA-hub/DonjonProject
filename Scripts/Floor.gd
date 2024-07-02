extends Node

signal mouse_clicked(_position:Vector3)
signal mouse_hover(_position:Vector3)
var children
var right_mouse_pressed = false
signal combat_started(Array)

func _ready():
	children = get_children()
	for child in children:
		child.input_event.connect(_on_ground_input_event)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2:
			if event.pressed:
				right_mouse_pressed = true
			else : 
				right_mouse_pressed = false
	

func _on_ground_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouse:
		if right_mouse_pressed :
			mouse_clicked.emit(_position)
		
		mouse_hover.emit(_position)
	
func start_combat(opponents : Array):
	combat_started.emit(opponents)
