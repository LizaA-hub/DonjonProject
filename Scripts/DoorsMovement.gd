extends Node

@export var FirstDoor : Node3D
@export var SecondDoor : Node3D
@export var ThirdDoor : Node3D
var has_ally = false
var player
var ally
signal door_opening(Vector3)
var can_move = false
var door_to_move : int
var camera

func _ready():
	get_node("/root/Node3D/Bar").is_free.connect(NPC_free)
	player = %player
	ally = %prisoner
	camera = %MainCamera
				
func NPC_free():
	has_ally = true

func start_door_animation():
	player.door_opening()
	ally.door_opening(FirstDoor.global_position)
	
func open_first_door() -> void:
	FirstDoor.animator.play("DoorOpening")

func open_third_door():
	camera.is_in_cinematic = true
	var camera_rotation = camera.rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var rooms = [$"../LigthArea/FisrtRoomArea",$"../LigthArea/corridorArea4",$"../LigthArea/corridorArea5"]
	for room in rooms:
		room.light_on()
	
	var tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(camera,"position",Vector3(28,16,-19),1)
	tween.tween_interval(0.5)
	tween.tween_callback(ThirdDoor.animator.play.bind("DoorOpening"))
	tween.tween_interval(2)
	
	await tween.finished
	camera.reset_position(camera_rotation,0.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for room in rooms:
		room.light_off()
