extends StaticBody3D

@onready var meshes = [$StoneDoor,$MetalFrame,$MetalFrame2,$RightLock/MetalFrame3,$LeftLock/MetalFrame4]

func _toggle_visibility( _on : bool):
	for mesh in meshes:
		if _on:
			mesh.set_layer_mask_value(3,true)
			mesh.set_layer_mask_value(2,false)
		else:
			mesh.set_layer_mask_value(3,false)
			mesh.set_layer_mask_value(2,true)
