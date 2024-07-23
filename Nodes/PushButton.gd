extends EnvironmentAsset

var meshes : Array[MeshInstance3D]
var parent
var player

func _ready():
	meshes = [$Box,$Button]
	parent = get_parent()
	if parent== null:
		print(name, " : parent not found")
		
	player = %player
	
func _on_mouse_entered():
	$Outline.visible = true

func _on_mouse_exited():
	if $Outline.visible:
		$Outline.visible = false
	
func _toggle_visibility( _on : bool):
	for mesh in meshes:
		if _on:
			mesh.set_layer_mask_value(3,true)
			mesh.set_layer_mask_value(2,false)
		else:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(2,true)


func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				player.try_interact(self)

func interact() -> void:
	parent.open_third_door()
