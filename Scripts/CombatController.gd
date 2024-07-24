extends Node

var navigation_region
signal combat_started
signal combat_stopped
var opponents : Array
var turn : int = -1
var CombatUI 
var first_combat = true
var camera
var game_over_screen
var wall_parent

func _ready():
	navigation_region = $"../NavigationRegion3D"
	navigation_region.combat_started.connect(start_combat)
	camera = %MainCamera
	game_over_screen = $"../UI/GameOver"
	wall_parent = $"../Borders"
	
func start_combat(_opponents : Array):
	opponents = _opponents
	if first_combat:
		start_first_combat()
	else:
		combat_started.emit()
		next_turn()
	
	
func next_turn():
	if opponents.is_empty():
		return
		
	turn += 1
	if turn>= opponents.size():
		turn = 0
	opponents[turn].set_turn()
	#print("next turn : ",opponents[turn])

func get_target(type : String):
	if opponents.size() <= 1:
		return null
		
	var target = opponents.pick_random()
	if type == "ally":
		if target.is_in_group("enemy"):
			return get_target(type)
		else:
			return target
	elif type == "enemy":
		if target.is_in_group("enemy"):
			return target
		else:
			return get_target(type)
	else:
		#print("combat controller : invalid get target argument")
		return null
		
func remove_opponent(opponent):
	opponents.erase(opponent)
	for _opponent in opponents:
		if _opponent.is_in_group("enemy"):
			for ally in opponents:
				if !ally.is_in_group("enemy"):
					return
	end_combat()
	
func target_validity(target,type):
	if opponents.has(target):
		return target
	else:
		return get_target(type)
		
func end_combat():
	#print("combat controller : stopping combat")
	opponents.clear()
	combat_stopped.emit()
	navigation_region.combat_ended()
	
func add_opponent(new_opponent):
	opponents.append(new_opponent)

func start_first_combat() -> void:
	first_combat = false
	camera.is_in_cinematic = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !toggle_walls(true):
		print("combat controller can't turn walls on")
	var previous_camera_rotation = camera.rotation
	var tween = get_tree().create_tween()
	
	tween.tween_interval(0.5)
	
	tween.tween_property(camera,"position",Vector3(0,2,-61),0.5)
	tween.parallel().tween_property(camera,"rotation_degrees",Vector3(-15,0,0),0.5)
	
	tween.tween_interval(1.5)
	await tween.finished
	tween.kill()
	tween = get_tree().create_tween()
	
	camera.position=Vector3(-8,2,-66)
	camera.rotation_degrees=Vector3.ZERO
	
	tween.tween_interval(1.5)
	await tween.finished
	tween.kill()
	tween = get_tree().create_tween()
	
	camera.position=Vector3(0,2,-58)
	camera.rotation_degrees=Vector3(0,-180,0)
	
	tween.tween_interval(1.5)
	await tween.finished
	camera.reset_position(previous_camera_rotation,0.5)
	if !toggle_walls(false):
		print("combat controller can't turn walls off")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	combat_started.emit()
	next_turn()
	
func game_over() -> void:
	end_combat()
	
	camera.is_in_cinematic = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if !toggle_walls(true):
		print("combat controller can't turn walls on")

	var tween = get_tree().create_tween()
	tween.tween_property(camera,"position",Vector3(%player.global_position.x + 4,4,%player.global_position.z),0.5)
	tween.parallel().tween_callback(camera.look_at.bind(%player.global_position))
	tween.tween_interval(0.5)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	game_over_screen.visible = true
	tween.tween_property(game_over_screen,"modulate",Color(1,1,1,1),0.5)
	
	
func toggle_walls(on : bool) -> bool:
	var children = wall_parent.find_children("Wall")
	if children.is_empty():
		print("toggle walls : invalid get_children")
		return false
	for child in children:
		child.toggle_visibility(on)
		
	#toggle first corridor visibility
	$"../LigthArea/corridorArea".toggle_visibility(on)
	return true
