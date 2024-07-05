extends MarginContainer

var item_nodes : Array

func _ready():
	item_nodes.append($BGSlot/TextureButton/ItemDisplay/Item)
	item_nodes.append($BGSlot/TextureButton/PressedTexture/Item)
	item_nodes.append($BGSlot/TextureButton/HoverTexture/Item)
	item_nodes.append($BGSlot/TextureButton/DisableTexture/Item)
	
func display_item(item : Texture2D):
	if item == null:
		for node in item_nodes:
			node.visible = false
	else:
		for node in item_nodes:
			node.visible = true
			node.set_texture(item)
	
func display_quantity(value : int):
	if value == 0 :
		$BGSlot/Label.visible = false
		return
	$BGSlot/Label.visible = true
	$BGSlot/Label.text = String.num(value)
