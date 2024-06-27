extends PanelContainer

var vertical_container

func _ready():
	vertical_container = $ScrollContainer/VBoxContainer

func _process(_delta):
	#scaling with screen
	var _scale = DisplayServer.window_get_size().y/1080.0
	var scale_vect = Vector2(_scale,_scale)
	set_scale(scale_vect)
	if Input.is_key_pressed(KEY_SPACE):
		print( "current UI scale : " , get_scale())
		print( "window size : " , DisplayServer.window_get_size())
		print(  "screen size : " , DisplayServer.screen_get_size())
		
	#scaling with cntent
	var _size = get_size()
	_size.y = min(vertical_container.size.y,270)
	set_size(_size)
	set_pivot_offset(Vector2(0,_size.y/2))
