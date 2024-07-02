extends MarginContainer
var current_displayed_character


func set_texture(viewport : Viewport):
	viewport.actualize()
	$HBoxContainer/TextureRect.set_texture(viewport.get_texture())
	
func display_name(_name : String):
	$HBoxContainer/VBoxContainer/Name.text = _name

func set_max_health(_max : int):
	$HBoxContainer/VBoxContainer/LifeBar.max_value = _max
	
func set_health(_value : int):
	$HBoxContainer/VBoxContainer/LifeBar.value = _value
	
func initialize(character):
	if current_displayed_character != null and current_displayed_character.health_changed.is_connected(set_health):
		current_displayed_character.health_changed.disconnect(set_health)
		current_displayed_character.energy_changed.disconnect(set_energy)
		
	current_displayed_character = character
	set_texture(character.viewport)
	display_name(character.pseudo)
	set_max_health(character.max_health)
	set_max_energy(character.max_energy)
	if character.health != null:
		set_health(character.health)
		set_energy(character.energy)
	else:
		print(character.name, "'s health is null")
	character.health_changed.connect(set_health)
	character.energy_changed.connect(set_energy)
	
func set_max_energy(_max : int):
	$HBoxContainer/VBoxContainer/EnergyBar.max_value = _max
	
func set_energy(_value : int):
	$HBoxContainer/VBoxContainer/EnergyBar.value = _value
		
