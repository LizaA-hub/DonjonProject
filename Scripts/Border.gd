extends StaticBody3D


func _toggle_visibility( _on : bool):
	#print("floor tile toogle visibility : ", _on)
	if !$Wall.visible and !$Wall.is_hiden:
		$Wall.visible = true
		
	if _on:
		$MeshInstance3D.set_layer_mask_value(3,true)
		$MeshInstance3D.set_layer_mask_value(2,false)

		$Wall.set_layer_mask_value(3,true)
		$Wall.set_layer_mask_value(2,false)
	else:
		$MeshInstance3D.set_layer_mask_value(3,false)
		$MeshInstance3D.set_layer_mask_value(2,true)

		$Wall.set_layer_mask_value(3,false)
		$Wall.set_layer_mask_value(2,true)
