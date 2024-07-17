extends MeshInstance3D

enum Layers{FIRST_LAYER , SECOND_LAYER , THIRD_LAYER, NONE}
@export var layer : Layers = Layers.NONE
@onready var player = %player
var is_hiden = false

func _process(_delta):
	if layer == Layers.NONE:
		return
		
	if player.global_position.x > 16:
		if layer == Layers.FIRST_LAYER:
			visible = false
			is_hiden = true
		else:
			is_hiden = false
	elif player.global_position.x < 16 and player.global_position.x > -24:
		if layer == Layers.SECOND_LAYER:
			visible = false
			is_hiden = true
		else:
			is_hiden = false
	else:
		if layer == Layers.THIRD_LAYER:
			visible = false
			is_hiden = true
		else:
			is_hiden = false
