extends PanelContainer

@export var vertical_container : VBoxContainer
@export var pivot_position : Vector2

var is_in_combat = false

func _ready():
	var combat_controller = %CombatController
	combat_controller.combat_mode.connect(toggle_combat)
	visible = false
	
#func _process(_delta):
	#var screen_size = DisplayServer.window_get_size()
	##scaling with screen
	#var _scale = screen_size.y/1080.0
	#var scale_vect = Vector2(_scale,_scale)
	#set_scale(scale_vect)

	#scaling with cntent
	#var _size = get_size()
	#_size.y = min(vertical_container.size.y + 20,270)
	#set_size(_size)
	#set_pivot_offset(Vector2(_size.x * pivot_position.x,_size.y*pivot_position.y))
	
	#position
	#position = Vector2(screen_size.x - 200*screen_size.x/1080.0, position.y)
	#if Input.is_key_pressed(KEY_SPACE):
		#print(_size*_scale)
	
func set_buttons(target_type : String):
	var set_visibility = true
	$VBoxContainer/EndTurnButton.visible = is_in_combat
	
	if target_type == "ally":
		set_visibility = false
		
	$VBoxContainer/AttackButton.visible = set_visibility
	$VBoxContainer/SpecialAttackButton.visible = set_visibility
	
func toggle_combat():
	is_in_combat = !is_in_combat
	print("Actions menu set combat bool to : ", is_in_combat)
