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
	health = max_health
	name_display = $Label
	#if character_name != "":
		#name_display.text = character_name
	progress_bar = $TextureProgressBar
	progress_bar.max_value = max_health
	value_display = $Label2
	set_health(health)
	
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
