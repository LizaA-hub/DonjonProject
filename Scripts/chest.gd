extends EnvironmentAsset
var player 
var can_open
var is_empty = false

func _ready():
	player = $"../../player"
	player.interact.connect(open)
	
	
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				if is_empty:
					return
					
				can_open = true
				player.try_interact(global_position)

func open(_value):
	if !can_open:
		return
		
	$AnimationPlayer.play("chest_opening")
	can_open = false
	player.unlock_weapon()
	is_empty = true
