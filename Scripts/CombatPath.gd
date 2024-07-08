extends Node3D

var player
var current_line
@onready var destination = global_position
var drawing_line = false

func initialize(mouse_signal, exit_mouse_signal, mouse_on_ui):
	player = get_parent()
	mouse_signal.connect(draw_mouse_line)
	exit_mouse_signal.connect(hide_line)
	mouse_on_ui.connect(hide_line)
	

func draw_line(origin:Vector3,end : Vector3, color = Color.WHITE) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = false
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES,material)
	immediate_mesh.surface_add_vertex(origin)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	return mesh_instance
	
func draw_mouse_line(_position : Vector3):
	if current_line != null:
		current_line.queue_free()
	
	var origin = global_position
	
	var distance = min(origin.distance_to(_position), 5)
	destination = origin - ((origin - _position).normalized() * distance)
	destination.y = 0.5
	origin.y = 0.5
	current_line = draw_line(origin,destination)
	if !$Target.visible:
		$Target.visible=true
	$Target.global_position = destination
	
func deactivate(_signal, mouse_exit_signal,mouse_on_ui):
	_signal.disconnect(draw_mouse_line)
	mouse_exit_signal.disconnect(hide_line)
	mouse_on_ui.disconnect(hide_line)
	
func get_target_position():
	return destination
	


func hide_line():
	if current_line != null:
		current_line.queue_free()
	$Target.visible=false
