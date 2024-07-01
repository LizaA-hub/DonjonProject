extends PanelContainer

@export var vertical_container : VBoxContainer
@export var pivot_position : Vector2

func _process(_delta):
	#scaling with screen
	var _scale = DisplayServer.window_get_size().y/1080.0
	var scale_vect = Vector2(_scale,_scale)
	set_scale(scale_vect)

	#scaling with cntent
	var _size = get_size()
	_size.y = min(vertical_container.size.y,270)
	set_size(_size)
	set_pivot_offset(Vector2(_size.x * pivot_position.x,_size.y*pivot_position.y))
	

