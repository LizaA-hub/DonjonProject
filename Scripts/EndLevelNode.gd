extends Node3D

var pop_up
var player
var camera
var ally
var menu
var audio_manager

func _ready():
	pop_up = %PopUp
	player = %player
	camera = %MainCamera
	ally = %prisoner
	menu = $"../../UI/Control"
	audio_manager = %AudioManager
	$Area3D.initialize(pop_up,player,camera,ally, menu,audio_manager)
