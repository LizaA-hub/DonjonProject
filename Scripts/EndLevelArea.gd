extends Node3D

@onready var meshes = [$ExternHallo,$InternHallo]

func _toggle_visibility( _on : bool):
	#print("hallo area : visibility toggled")
	for mesh in meshes:
		if _on:
			mesh.set_layer_mask_value(3,true)
			mesh.set_layer_mask_value(2,false)
		else:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(2,true)
