class_name Item

extends EnvironmentAsset

var player 
#var can_pick
enum types {KEY,HEALTH_POTION, ENERGY_POTION}
@export var type : types
@export var power : int
@export var quantity : int
@export var item_name : String
@export var description : String

func _ready():
	player = %player
	player.interact.connect(pick_up)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				#can_pick = true
				player.try_interact(self)

func interact():
	pick_up()
	
func pick_up():
	#if !can_pick:
		#return
	%InventorySystem.add_item(self)
	#print("is adding item to inventory")
	global_position.y = -11
	#can_pick = false
