extends Camera3D

@export var start_position : Vector3
@export var player : CharacterBody3D

func _ready():
	position = player.global_position + start_position
	look_at(player.global_position)
	
	$SpotLight3D2.global_position = start_position/2
	$SpotLight3D2.look_at(player.global_position)
	
func _physics_process(_delta):
	global_transform.origin = player.global_position + start_position
