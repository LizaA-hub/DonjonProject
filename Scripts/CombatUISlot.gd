extends HBoxContainer
var current_displayed_character


func set_texture(viewport : Viewport):
	viewport.actualize()
	$TextureRect.set_texture(viewport.get_texture())
	
func display_name(_name : String):
	$VBoxContainer/Name.text = _name

func set_max_health(_max : int):
	$VBoxContainer/LifeBar.max_value = _max
	
func set_health(_value : int):
	$VBoxContainer/LifeBar.value = _value
	
func initialize(character):
	if current_displayed_character != null and current_displayed_character.health_changed.is_connected(set_health):
		current_displayed_character.health_changed.disconnect(set_health)
		
	current_displayed_character = character
	set_texture(character.viewport)
	display_name(character.pseudo)
	set_max_health(character.max_health)
	if character.health != null:
		set_health(character.health)
	else:
		print(character.name, "'s health is null")
	character.health_changed.connect(set_health)
		
