extends Node

var is_open = false
var items : Array[Item]
var slots : Array[MarginContainer]
@export var item_textures : Dictionary


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
	
func toggle_inventory():
	set_slots()
	#print(items.size(), " items in the inventory")
	is_open = !is_open
	$Inventory.visible = is_open
	$ExitButton.visible = is_open

func add_item(item : Item):
	if items.size()!=0:
		for _item in items:
			if _item.type == item.type:
				_item.quantity += item.quantity
				return
				
	items.append(item)
	
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
	for _item in items:
		if _item.type == type:
			if _item.quantity > 1:
				_item.quantity -= 1
			else:
				items.erase(_item)
		return
	print("not item of type : ", type , " found in the inventory.")
