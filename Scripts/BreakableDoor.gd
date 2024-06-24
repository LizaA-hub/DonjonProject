extends EnvironmentAsset

var can_take_damage = false
var health = 10
var player

func _ready():
	player = $"../../player"
	player.interact.connect(take_damage)
	$HB.visible = false

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				can_take_damage = true
				player.try_attack(global_position)

func take_damage(_amout : float):
	if !can_take_damage:
		return
		
	health -= _amout
	if !$HB.is_visible_in_tree() and health < 10:
		$HB.visible = true
		
	
	if health<=0:
		disapear()
	$HB.set_health(health)
	
	can_take_damage = false
	
func disapear():
	global_position.y = -10
