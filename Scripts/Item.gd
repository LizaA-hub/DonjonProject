extends EnvironmentAsset

var player 
var can_pick
var is_empty = false

func _ready():
	player = $"../../player"
	player.interact.connect(pick_up)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				can_pick = true
				player.try_interact(global_position)

func pick_up(_value):
	if !can_pick:
		return
	player.can_open_door = true
	can_pick = false
	global_position.y = -11
	
