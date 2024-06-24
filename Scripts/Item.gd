extends EnvironmentAsset

var player 
var can_pick
var is_empty = false
enum types {KEY,HEALTH_POTION}
@export var type : types

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
	match(type):
		types.KEY:
			player.can_open_door = true
			global_position.y = -11
		types.HEALTH_POTION:
			player.heal(5)
			global_position.y = -11
	can_pick = false
	
	
