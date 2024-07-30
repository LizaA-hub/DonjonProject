class_name Audio

extends Node3D

var ST_player
var SFX_player
@export var ST_tracks : Dictionary
@export var SFX_tracks : Dictionary

func _ready():
	ST_player = $STplayer
	SFX_player = $SFXPlayer
	
func set_soundtrack(_name : String,fade : bool = true):
	if ST_tracks.has(_name):
		if fade:
			var tween = create_tween()
			tween.tween_property(ST_player,"volume_db",-80,0.5)
			tween.tween_callback(ST_player.set_stream.bind(ST_tracks[_name]))
			tween.tween_property(ST_player,"playing",true,0.1)
			tween.tween_property(ST_player,"volume_db",0,0.5)
			
		else:
			ST_player.set_stream(ST_tracks[_name])
			ST_player.playing = true

	else:
		print("audio manager :", _name, " not found")

		
func play(_name : String):
	if SFX_tracks.has(_name):
		#print("audio controler playing ", _name)
		SFX_player.set_stream(SFX_tracks[_name])
		SFX_player.playing = true

	else:
		print("audio manager :", _name, " not found")

func stop(stop_ST : bool = false) -> void:
	if stop_ST:
		ST_player.playing = false
	else:
		SFX_player.playing = false
