extends EnvironmentAsset

var can_take_damage = false
var health = 5
var player
var health_bar
var right_click_pressed = false
var decal2 = preload("res://Textures/BreakingDecal2.png")
var decal3 = preload("res://Textures/BreakingDecal3.png")
@export var particle_system : GPUParticles3D

func _ready():
	player = %player
	player.interact.connect(take_damage)
	health_bar = $SubViewport/Control
	health_bar.set_character_name( "door")
	health_bar.set_max_health(health)
	
	var ground = $"../../NavigationRegion3D"
	ground.right_click.connect(set_right_click)
	
func set_right_click(on : bool) -> void :
	right_click_pressed = on

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				can_take_damage = true
				player.try_attack(self)

func take_damage(_amout : float):
	if !can_take_damage:
		return
		
	if !$Decal.visible:
		$Decal.visible = true
		
	health -= _amout
	if health == 3:
		$Decal.texture_albedo = decal2
	elif health == 1:
		$Decal.texture_albedo = decal3
	
	if health<=0:
		disapear()
	health_bar.set_health(health)
	
	can_take_damage = false
	
func disapear():
	particle_system.emitting = true
	global_position.y = -10


func _on_mouse_entered():
	if !right_click_pressed:
		$Sprite3D.visible = true
	if player.has_weapon:
		$Outline.visible = true


func _on_mouse_exited():
	$Sprite3D.visible = false
	if $Outline.visible:
		$Outline.visible = false
