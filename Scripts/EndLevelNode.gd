extends Node3D

var pop_up
var player
var camera
var ally
var menu

func _ready():
	pop_up = %PopUp
	player = %player
	camera = %MainCamera
	ally = %prisoner
	menu = $"../../UI/Control"
	$Area3D.initialize(pop_up,player,camera,ally, menu)
