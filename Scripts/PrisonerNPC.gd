extends DefaultNPC

func _ready():
	timer = $"../Timer"
	timer.timeout.connect(_on_timer_timeout)
	
	MaxDistance = 3
	
	health_bar = $HealthBar
	
	ShowBubble("Sad")
	get_node("/root/Node3D/Bar").is_free.connect(get_free)
	get_node("/root/Node3D/Doors").door_opening.connect(open_door)

func get_free():
	ShowBubble("Love",2)
	combat_controller = $CombatController
	combat_controller.combat_mode.connect(start_combat)
	await create_tween().tween_interval(1).finished
	isFollowingPlayer = true
	speed = 400.0
	remove_from_group("dynamic")

func open_door(door : Vector3):
	look_at(door)
	ShowBubble("Surprise",1)
	await create_tween().tween_interval(1).finished
	$weapon.visible = true
	await create_tween().tween_interval(.5).finished
	$AnimationPlayer.play("MagicStickMovement")
	await create_tween().tween_interval(1).finished
	$AnimationPlayer.stop()
	$"..".start_interaction.emit()
	
func play_animation():
	$AnimationPlayer.play("MagicStickMovement")
	await create_tween().tween_interval(1).finished
	$AnimationPlayer.stop()
