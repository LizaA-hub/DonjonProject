extends EnvironmentAsset

var can_take_damage = false
var health = 10
var player
var health_bar

func _ready():
	player = %player
	player.interact.connect(take_damage)
	health_bar = $SubViewport/Control
	health_bar.set_character_name( "door")

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
	#if !$HB.is_visible_in_tree() and health < 10:
		#$HB.visible = true
		
	
	if health<=0:
		disapear()
	health_bar.set_health(health)
	
	can_take_damage = false
	
func disapear():
	global_position.y = -10


func _on_mouse_entered():
	$Timer.stop()
	$Sprite3D.visible = true


func _on_mouse_exited():
	$Timer.start(.5)


func _on_timer_timeout():
	$Sprite3D.visible = false
