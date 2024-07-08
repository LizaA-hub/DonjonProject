extends PanelContainer

@export var vertical_container : VBoxContainer
@export var pivot_position : Vector2

var is_in_combat = false
var player
var target
var inventory
signal mouse_on_panel()
var target_type

func _ready():
	var combat_controller = %CombatController
	combat_controller.combat_mode.connect(toggle_combat)
	visible = false
	
	player = %player
	
	inventory = $"../InventorySystem"
	
func set_buttons(_target_type : String):
	target_type = _target_type
	var can_attack = true
	var can_move_attack = false
	var can_move = false
	$VBoxContainer/EndTurnButton.visible = is_in_combat
	
	if target_type == "ally":
		can_attack = false
		
		if !player.can_attack(target.global_position):
			can_move = true
			
	else:
		if !player.can_attack(target.global_position):
			#print("player can'tattack")
			#print("target distance : ",player.global_position.distance_squared_to(target.global_position))
			if player.can_move_attack(target.global_position):
				can_attack = false
				can_move_attack = true
			else:
				#print("player can't move and attack")
				can_attack = false
				can_move = true
	
	$VBoxContainer/AttackButton.visible = can_attack
	$VBoxContainer/SpecialAttackButton.visible = can_attack
	$VBoxContainer/MoveAttack.visible = can_move_attack
	$VBoxContainer/Move.visible = can_move
	
func toggle_combat():
	is_in_combat = !is_in_combat
	#print("Actions menu set combat bool to : ", is_in_combat)


func _on_attack_button_button_down():
	target.can_take_damage = true
	player.try_attack(target)
	
func set_target(_target):
	target = _target


func _on_move_button_button_down():
	player.try_attack(target)


func _on_move_attack_button_button_down():
	target.can_take_damage = true
	player.try_attack(target)


func _on_end_turn_button_button_down():
	player.end_turn()


func _on_use_object_button_button_down():
	inventory.toggle_inventory()


func _on_mouse_entered():
	mouse_on_panel.emit()

func can_get_potion(potion_type : String, power : int) -> bool:
	if target_type == "enemy":
		return false
	if potion_type == "health":
		if target.health < target.max_health:
			target.take_potion(potion_type,power)
			
			if is_in_combat:
				player.end_turn()
				inventory.toggle_inventory(false)
		else:
			return false
	if potion_type == "energy":
		if target.energy < target.max_energy:
			target.take_potion(potion_type,power)
			if is_in_combat:
				player.end_turn()
				inventory.toggle_inventory(false)
		else:
			return false
	return true
