extends Control

var max_health : float = 10
var health
var energy
var max_energy
var character_name : String
var health_bar
var energy_bar
var name_display
var value_display
@export var is_ally : bool
@export var green : Color
@export var red : Color

func _ready():
	name_display = $Label
	health_bar = $HealthBar
	value_display = $Label2
	energy_bar = $EnergyBar
	
func initialize(pseudo : String, _max_health : int, health_signal:Signal, _max_energy: int, energy_signal : Signal):
	set_character_name(pseudo)
	set_max_health(_max_health)
	health_signal.connect(set_health)
	energy_signal.connect(set_energy)
	set_max_energy(_max_energy)
	
func set_health(_value : float):
	if _value <0:
		health = 0
	else:
		health = _value
		
	health_bar.value = health
	var text_value = String.num(health) + "/" + String.num(max_health)
	value_display.text = text_value
	if health > max_health/4 and is_ally:
		health_bar.tint_progress = green
	else:
		health_bar.tint_progress = red
	
func set_character_name(pseudo : String):
	name_display.text = pseudo
	
func set_max_health(_value):
	max_health = _value
	health_bar.max_value = max_health
	health = max_health
	set_health(health)
	
func set_energy(_value : float):
	if _value <0 :
		energy = 0
	else:
		energy = _value
	energy_bar.value = energy
	#print("health bar sets energy to : ", energy)

func set_max_energy(_value):
	max_energy = _value
	energy_bar.max_value = max_energy
	energy = max_energy
	set_energy(energy)
	#print("health bar sets max energy to : ", max_energy)
