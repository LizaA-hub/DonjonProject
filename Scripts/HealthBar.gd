extends Node3D

var camera 
var health = 1
@export var is_player : bool = false
@export var green : Color
@export var red : Color
var fill_material

func _ready():
	camera = get_node("/root/Node3D/Camera3D")
	fill_material = load("res://Materials/MI_HealthBar.tres").duplicate()
	if is_player:
		#print("changing health bar color")
		fill_material.albedo_color = green
	else:
		fill_material.albedo_color = red
	$FillAnchor/Fill.set_surface_override_material(0,fill_material)

func _process(_delta):
	look_at(camera.global_position)
	
func set_health(value : float):
	#print(value)
	health = value/10
	if health <= 1 and health >=0:
		$FillAnchor.scale.x = health
	else:
		print("invalid value for health set")
		health = 1
		
	if health <= 0.2 and is_player:
		fill_material.albedo_color = red
