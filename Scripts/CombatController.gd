extends Node

var navigation_region
signal combat_mode
var opponents : Array
var turn : int = -1
var CombatUI 

func _ready():
	navigation_region = $"../NavigationRegion3D"
	navigation_region.combat_started.connect(start_combat)
	CombatUI = $"../Control"
	
func start_combat(_opponents : Array):
	opponents = _opponents
	combat_mode.emit()
	CombatUI.set_ui(opponents)
	next_turn()
	
#func _input(_event):
	#if Input.is_key_pressed(KEY_SPACE):
		#print("it's ",opponents[turn], " turn." )
	
func next_turn():
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
	combat_mode.emit()
	
func add_opponent(new_opponent):
	opponents.append(new_opponent)
