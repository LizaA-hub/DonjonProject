extends DefaultNPC

signal start_interaction
var DoorManager

func _ready():
	startPosition = global_position
	ground = $"../../NavigationRegion3D"
	ground.right_click.connect(set_right_click)
	timer = $MoveTimer
	timer.timeout.connect(_on_move_timer_timeout)
	
	MaxDistance = 3
	
	health_bar = $SubViewport/Control
	health_bar_display = $Sprite3D
	health = max_health
	energy = max_energy
	health_bar.initialize(pseudo,max_health,health_changed,max_energy,energy_changed)
	
	ShowBubble("Sad")
	get_node("/root/Node3D/Bar").is_free.connect(get_free)
	DoorManager = get_node("/root/Node3D/Doors")
	
func get_free():
	ShowBubble("Love",2)
	combat_controller = %CombatController
	combat_controller.combat_started.connect(start_combat)
	combat_controller.combat_stopped.connect(stop_combat)
	await create_tween().tween_interval(1).finished
	isFollowingPlayer = true
	speed = 400.0
	remove_from_group("dynamic")

func door_opening(door : Vector3):
	look_at(door)
	ShowBubble("Surprise",1)
	await create_tween().tween_interval(1).finished
	$body/weapon.visible = true
	await create_tween().tween_interval(.5).finished
	play_animation("AttackSpe")
	await create_tween().tween_interval(1.5).finished
	DoorManager.open_first_door()
	
func play_animation(anim : String = "MagicStickMovement"):
	$AnimationPlayer.play(anim)
	if anim == "MagicStickMovement":
		await create_tween().tween_interval(1).finished
		$AnimationPlayer.stop()
