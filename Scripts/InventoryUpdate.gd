extends Control

@export var item_textures : Dictionary

func get_texture(key : String) -> Texture2D:
	if(item_textures.has(key)):
		return item_textures[key]
	else:
		print("inventory update display couldn't find the sprite ", key)
		return  null
		
func _enter_tree():
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0,1.5)
	tween.tween_property(self, "modulate", Color(1,1,1,0),2)
	await tween.finished
	queue_free()
	
func set_sprite(key: String) -> void:
	$MarginContainer/HBoxContainer/TextureRect.texture = get_texture(key)

func set_label(message : String) -> void:
	$MarginContainer/HBoxContainer/Label.text = message
