extends Control

var viewport
var opponents : Array
var slots : Array
var slot_template

func _ready():
	#viewport = %SubViewport
	#$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer4/TextureRect.set_texture(viewport.get_texture())
	slots = $PanelContainer/ScrollContainer/VBoxContainer.get_children()
	slot_template = slots[0]

func set_ui(_opponents):
	opponents = _opponents
	var gap = opponents.size() - slots.size()
	if gap >0:
		for i in gap:
			slots.append(slot_template.duplicate())
			
	for i in slots.size():
		slots[i].set_texture(opponents[i].viewport)
		slots[i].display_name(opponents[i].pseudo)
		slots[i].set_max_health(opponents[i].max_health)
		slots[i].set_health(opponents[i].health)
		
	$PanelContainer.visible = true
	
func close_UI():
	$PanelContainer.visible = false
	if slots.size() >2:
		var gap = slots.size()-2
		for i in gap:
			slots[i+2].queue_free()
		slots.resize(2)
