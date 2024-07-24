extends Node3D

var player 
var is_empty = false
var open_position
signal is_free
var is_opened = false
var outlines : Array[Node]

func _ready():
	player = %player
	open_position= global_position
	open_position.y = -10
	outlines = find_children("Outline")
	
func _on_clickable_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				player.try_interact(self,_position)
				
func interact() -> void:
	if player.can_open_door() and !is_opened:
		move_down()
	else:
		player.ShowBubble("Question",2)

func move_down():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",open_position,2)
	is_opened = true
	is_free.emit()
	player.remove_item(Item.types.KEY)

func _on_clickable_mouse_entered():
	if player.can_open_door() and !is_opened:
		if !toggle_outline(true):
			print("prison movement : can't show outlines")

func _on_clickable_mouse_exited():
	if !toggle_outline(false):
		print("prison movement : can't hide outlines")

func toggle_outline(on:bool) -> bool:
	if outlines.is_empty():
		print("prison movement : can't find outline children")
		return false
		
	for outline in outlines:
		outline.visible = on
		
	return true
