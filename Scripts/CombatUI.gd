extends ScrollContainer

var viewport
var opponents : Array
var slots : Array
var slot_template
var vertical_container

func _ready():
	var navigation_region = $"../../NavigationRegion3D"
	navigation_region.combat_started.connect(set_ui)
	
	vertical_container = $PanelContainer/VBoxContainer
	slots = vertical_container.get_children()
	slot_template = slots[0]
	
	var combat_controller = %CombatController
	combat_controller.combat_stopped.connect(close_UI)
	
	$PanelContainer.visible = false

func set_ui(_opponents):
	opponents = _opponents
	var gap = opponents.size() - slots.size()
	if gap >0:
		for i in gap:
			var new_slot = slot_template.duplicate()
			vertical_container.add_child(new_slot)
			slots.append(new_slot)
			
	for i in slots.size():
		slots[i].initialize(opponents[i])
		
	$PanelContainer.visible = true
	
func close_UI():
	if !$PanelContainer.visible:
		return
		
	$PanelContainer.visible = false
	if slots.size() >2:
		var gap = slots.size()-2
		for i in gap:
			slots[i+2].queue_free()
		slots.resize(2)

