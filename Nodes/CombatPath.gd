extends Node3D

var player
var current_line

func initialize(mouse_signal):
	player = get_parent()
	mouse_signal.connect(draw_mouse_line)
	

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
	
	add_child(mesh_instance)
	
	return mesh_instance
	
func draw_mouse_line(_position : Vector3):
	var destination = _position
	if current_line != null:
		current_line.queue_free()
		
	#var distance = global_position.distance_squared_to(destination)
	#if distance > 16:
		#destination = _position.normalized() * 4
	destination.y = 0.6
	current_line = draw_line(global_position,destination)
	$Target.global_position = destination
	

