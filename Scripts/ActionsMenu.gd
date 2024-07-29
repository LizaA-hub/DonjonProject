extends Control

var is_in_combat = false
var player
var target
var inventory
var inventory_open = false
signal mouse_on_panel()
var target_type
var indications : Label
var panel_open = false
var ground


func _ready():
	var combat_controller = %CombatController
	combat_controller.combat_started.connect(toggle_combat)
	combat_controller.combat_stopped.connect(toggle_combat)
	visible = false
	
	player = %player
	inventory = %InventorySystem
	ground = $"../../NavigationRegion3D"
	ground.mouse_event.connect(close_panel)
	
	indications = Label.new()
	get_tree().get_root().add_child.call_deferred(indications)
	var indication_position = global_position
	indication_position.x -= 100
	indications.global_position = indication_position
	
func set_buttons(_target_type : String):
	if target == null:
		return
		
	visible = true

	target_type = _target_type
	var can_attack = true
	var can_move_attack = false
	var can_move = false
	$AspectRatioContainer/PanelContainer/VBoxContainer/EndTurnButton.visible = is_in_combat
	
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
	
	$AspectRatioContainer/PanelContainer/VBoxContainer/AttackButton.visible = can_attack
	if player.energy < 5:
		can_attack = false
	$AspectRatioContainer/PanelContainer/VBoxContainer/SpecialAttackButton.visible = can_attack
	$AspectRatioContainer/PanelContainer/VBoxContainer/MoveAttack.visible = can_move_attack
	$AspectRatioContainer/PanelContainer/VBoxContainer/Move.visible = can_move

	panel_open = true
	
func toggle_combat():
	is_in_combat = !is_in_combat
	#print("Actions menu set combat bool to : ", is_in_combat)


func _on_attack_button_button_down():
	%AudioManager.play("DefaultUI")
	target.can_take_damage = true
	player.try_attack(target)
	
func set_target(_target) -> bool:
	if target == _target:
		return false
		
	target = _target
	return true
	

func _on_move_button_button_down():
	%AudioManager.play("DefaultUI")
	player.try_attack(target)


func _on_move_attack_button_button_down():
	%AudioManager.play("DefaultUI")
	target.can_take_damage = true
	player.try_attack(target)


func _on_end_turn_button_button_down():
	%AudioManager.play("DefaultUI")
	player.end_turn()


func _on_use_object_button_button_down():
	%AudioManager.play("DefaultUI")
	inventory.toggle_inventory()
	inventory_open = !inventory_open


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


func _on_special_attack_button_button_down():
	%AudioManager.play("DefaultUI")
	target.can_take_damage = true
	player.try_attack(target,true)


func _on_attack_button_mouse_entered():
	show_indications(1)

func _on_special_attack_button_mouse_entered():
	show_indications(5)
	
func show_indications(_value : float) -> void :
	indications.visible = true
	indications.text = "%d damage \n - %d energy" %[_value,_value]

func hide_indications() -> void:
	indications.visible = false

func _on_attack_button_mouse_exited():
	hide_indications()


func _on_special_attack_button_mouse_exited():
	hide_indications()

func target_died(_target):
	if _target == target:
		close_panel()
	
func close_panel() -> void:
	if !visible:
		return

	panel_open = false
	visible = false
	if inventory.is_open:
		inventory.toggle_inventory(false)
		inventory_open = !inventory_open
	set_target(null)
