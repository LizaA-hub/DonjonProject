extends Control

func _ready():
	var player = %player
	player.player_turn.connect(set_turn_ui)
	
	
func set_turn_ui(is_player_turn : bool):
	$Label.visible = is_player_turn
