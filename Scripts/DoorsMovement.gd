extends Node

@export var FirstDoor : StaticBody3D
@export var SecondDoor : StaticBody3D
@export var ThirdDoor : StaticBody3D
var has_ally = false
var player
signal door_opening(Vector3)
var can_move = false
var door_to_move : int

func _ready():
	get_node("/root/Node3D/Bar").is_free.connect(NPC_free)
	$"../prisoner".start_interaction.connect(move_down)
	player = get_node("/root/Node3D/player")
	player.interact.connect(open_door)


func _on_static_body_3d_3_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed() and has_ally:
				player.try_interact(_position)
				can_move = true
				door_to_move = 1
				
				
func NPC_free():
	has_ally = true

func open_door(_value):
	if can_move:
		if door_to_move == 1:
			door_opening.emit(FirstDoor.global_position)
			player.door_opening(FirstDoor.global_position)
			can_move = false
		else:
			move_down(door_to_move)
			can_move = false
		
	
func move_down(value = 1):
	var door = FirstDoor
	if value ==2:
		door = SecondDoor
	elif value == 3:
		door = ThirdDoor
		
	var open_position = door.global_position
	open_position.y = -10

	var tween = get_tree().create_tween()
	tween.tween_property(door,"position",open_position,1)


func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed() and has_ally:
				player.try_interact(_position)
				can_move = true
				door_to_move = 2


func _on_button_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed() and has_ally:
				player.try_interact(_position)
				can_move = true
				door_to_move = 3
