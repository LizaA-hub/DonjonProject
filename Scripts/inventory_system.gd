extends Node

var is_open = false
@export var items : Array[Item]
var slots : Array[MarginContainer]
@export var item_textures : Dictionary
var rich_text
var selected_item : Item
var interraction_panel
var update_node


func _ready():
	slots.append($Inventory/GridContainer/Slot1)
	slots.append($Inventory/GridContainer/Slot2)
	slots.append($Inventory/GridContainer/Slot3)
	slots.append($Inventory/GridContainer/Slot4)
	slots.append($Inventory/GridContainer/Slot5)
	slots.append($Inventory/GridContainer/Slot6)
	slots.append($Inventory/GridContainer/Slot7)
	slots.append($Inventory/GridContainer/Slot8)
	slots.append($Inventory/GridContainer/Slot9)
	
	#for slot in slots:
		#slot.gui_input.connect(on_double_click)
	
	rich_text = $Description
	interraction_panel = %InteractionUI
	
	update_node = preload("res://Nodes/InventoryUpdate.tscn")
	
func toggle_inventory(open : bool = !is_open) -> void:
	set_slots()
	#print("toggle inventory : ", open)
	is_open = open
	$Inventory.visible = is_open
	$ExitButton.visible = is_open
	if !is_open:
		rich_text.visible = is_open

func add_item(item : Item):
	if items.size()!=0:
		for _item in items:
			if _item.type == item.type:
				_item.quantity += item.quantity
				return
				
	items.append(item)
	var quantity = "+"
	if item.quantity > 1:
		quantity = "+ " + (String).num(item.quantity)
		
	display_update(item.type,quantity)
	
func set_slots():
	for i in slots.size():
		if i < items.size():
			slots[i].display_item(get_texture(items[i].type))
			slots[i].display_quantity(items[i].quantity)
		else:
			slots[i].display_item(null)
			slots[i].display_quantity(0)
			
func get_texture(type):
	match(type):
		Item.types.KEY:
			return item_textures["Key"]
		Item.types.HEALTH_POTION:
			return item_textures["HealthPotion"]
		Item.types.ENERGY_POTION:
			return item_textures["EnergyPotion"]
	return null

func inventory_has(type : Item.types) -> bool:
	for item in items:
		if item.type == type:
			return true
	return false
	
func remove(type : Item.types) -> void:
	var item_to_erase = null
	for _item in items:
		if _item.type == type:
			if _item.quantity > 1:
				_item.quantity -= 1
				set_slots()
				display_update(type,"-")
				return
			else:
				item_to_erase = _item
	if item_to_erase != null:
		items.erase(item_to_erase)
		set_slots()
		display_update(type,"-")
		return
	print("not item of type : ", type , " found in the inventory.")
	
func item_selected(slot : MarginContainer) -> void:
	rich_text.visible = false
	for i in slots.size():
		if slots[i] == slot :
			if items.size()>i:
				selected_item = items[i]
				display_description(items[i])
			else:
				selected_item = null
			return
	print("iventory system: no item corresponding to the slot")
		
func display_description(item : Item) -> void :
	rich_text.visible = true
	rich_text.text = ""
	var displayed_name = "[b]" + item.item_name + "[/b] \n"
	var displayed_description = item.description
	rich_text.push_font_size(20)
	rich_text.text = displayed_name
	rich_text.append_text(displayed_description)

func on_double_click(event : InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_double_click():
				if selected_item ==null:
					#print("double click : no item selected")
					return
				use(selected_item)
				#print("using item")
				
func use(item : Item) -> void:
	match item.type:
		Item.types.KEY:
			return 
		Item.types.HEALTH_POTION:
			if interraction_panel.can_get_potion("health", item.power):
				remove(Item.types.HEALTH_POTION)
		Item.types.ENERGY_POTION:
			if interraction_panel.can_get_potion("energy", item.power):
				remove(Item.types.ENERGY_POTION)
			
func display_update(type : Item.types, message : String):
	var update = update_node.instantiate()
	match type:
		Item.types.KEY:
			update.set_sprite("Key")
		Item.types.HEALTH_POTION:
			update.set_sprite("RedPotion")
		Item.types.ENERGY_POTION:
			update.set_sprite("BluePotion")
			
	update.set_label(message)
	get_tree().root.add_child(update)
	
	
