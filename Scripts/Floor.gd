extends Node

signal mouse_clicked(_position:Vector3)
signal mouse_hover(_position:Vector3)
signal combat_started(Array)
signal mouse_not_on_ground
signal right_click(bool)
signal mouse_event
var children
var right_mouse_pressed = false
var mouse_on_child =0
var signal_sent = false

func _ready():
	children = get_children()
	for child in children:
		child.input_event.connect(_on_ground_input_event)
		child.mouse_exited.connect(_on_ground_mouse_exited)
		child.mouse_entered.connect(_on_ground_mouse_entered)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2:
			if event.pressed:
				right_mouse_pressed = true
				right_click.emit(true)
			else : 
				right_mouse_pressed = false
				right_click.emit(false)

func _process(_delta):
	
	if mouse_on_child == 0 and !signal_sent:
		mouse_not_on_ground.emit()
		signal_sent = true
	

func _on_ground_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		mouse_event.emit()
	if event is InputEventMouse:
		if right_mouse_pressed :
			mouse_clicked.emit(_position)
		
		mouse_hover.emit(_position)
		signal_sent = false
	
func start_combat(opponents : Array, room_nodes : Array) -> void:
	for child in children:
		if !room_nodes.has(child):
			child.input_ray_pickable = false
			
	combat_started.emit(opponents)
	
func _on_ground_mouse_exited():
	mouse_on_child -= 1
	
func _on_ground_mouse_entered():
	mouse_on_child += 1
	
func combat_ended():
	for child in children:
		child.input_ray_pickable = true
