extends Control

var max_health : float = 10
var health
var character_name : String
var progress_bar
var name_display
var value_display
@export var is_ally : bool
@export var green : Color
@export var red : Color

func _ready():
	name_display = $Label
	progress_bar = $TextureProgressBar
	value_display = $Label2
	
func initialize(pseudo : String, _max_health : int, _signal:Signal):
	set_character_name(pseudo)
	set_max_health(_max_health)
	set_signal(_signal)
	
func set_health(_value : float):
	health = _value
	progress_bar.value = health
	var text_value = String.num(health) + "/" + String.num(max_health)
	value_display.text = text_value
	if health > max_health/4 and is_ally:
		progress_bar.tint_progress = green
	else:
		progress_bar.tint_progress = red
	
func set_character_name(pseudo : String):
	name_display.text = pseudo
	
func set_max_health(_value):
	max_health = _value
	progress_bar.max_value = max_health
	health = max_health
	set_health(health)
	
func set_signal(_signal : Signal):
	_signal.connect(set_health)
