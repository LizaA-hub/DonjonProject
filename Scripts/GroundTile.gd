class_name EnvironmentAsset

extends StaticBody3D

func _toggle_visibility( _on : bool):
	#print("floor tile toogle visibility : ", _on)
	if _on:
		$MeshInstance3D.set_layer_mask_value(3,true)
		$MeshInstance3D.set_layer_mask_value(2,false)
	else:
		$MeshInstance3D.set_layer_mask_value(3,false)
		$MeshInstance3D.set_layer_mask_value(2,true)
