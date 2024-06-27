extends HBoxContainer


func set_texture(viewport : Viewport):
	$TextureRect.set_texture(viewport.get_texture())
	
func display_name(_name : String):
	$VBoxContainer/Name.text = _name

func set_max_health(_max : int):
	$VBoxContainer/LifeBar.max_value = _max
	
func set_health(_value : int):
	$VBoxContainer/LifeBar.value = _value
	
