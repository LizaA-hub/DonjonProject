extends EnvironmentAsset

var meshes : Array[MeshInstance3D]

func _ready():
	meshes = [$Box,$Button]
	
	
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
