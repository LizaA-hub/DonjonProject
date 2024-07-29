extends Camera3D

@export var start_position : Vector3
@export var player : CharacterBody3D
var is_in_cinematic = false

func _ready():
	position = player.global_position + start_position
	look_at(player.global_position)
	
	$SpotLight3D2.global_position = start_position/2
	$SpotLight3D2.look_at(player.global_position)
	
func _physics_process(_delta):
	if is_in_cinematic:
		return
	global_transform.origin = player.global_position + start_position
	
func reset_position(previous_rotation : Vector3, duration : float = 0.5) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", previous_rotation,duration)
	tween.parallel().tween_property(self, "position", player.global_position + start_position,duration)
	await tween.finished
	is_in_cinematic = false
