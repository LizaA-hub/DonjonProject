extends Area3D
var isVisible = false
var is_lighten = false
@onready var player = %player
@export var Adjacent1 : Area3D
@export var Adjacent2 : Area3D
@export var Adjacent3 : Area3D
@export var Adjacent4 : Area3D
var AdjacentArea : Array
var room_nodes
var timer = 0
var init = true
var navigation_region


func _ready():
	navigation_region = $"../../NavigationRegion3D"
	AdjacentArea = Array()
	if Adjacent1 != null :
		AdjacentArea.append(Adjacent1)
		if Adjacent2 != null:
			AdjacentArea.append(Adjacent2)
			if Adjacent3 != null:
				AdjacentArea.append(Adjacent3)
				if Adjacent4 != null:
					AdjacentArea.append(Adjacent4)
		
func _on_body_entered(body):
	var opponents = Array()
	
	if body.is_in_group("dynamic") or body.is_in_group("environment"):
		room_nodes = get_overlapping_bodies()
		if !room_nodes.has(player):
			body.visible = false
			is_lighten = false
	
	if body.name == "player":
		opponents.append(body)
		room_nodes = get_overlapping_bodies()
		#print("player entering the room")
		for node in room_nodes:
			#print(node.name)
			if node.is_in_group("environment"):
		#light environment nodes
				node.visible = true
				node._toggle_visibility(true)
		#show dynamic nodes
			if node.is_in_group("dynamic"):
				#print(node.name)
				node.visible = true
			if node.is_in_group("enemy"):
				node.ShowBubble()
				opponents.append(node)
				
		toggle_adjacent_visibility(true)
		is_lighten = true
		
		if opponents.size() > 1:
			navigation_region.start_combat(opponents)

func _on_body_exited(body):
	if body.name == "player":
		room_nodes = get_overlapping_bodies()
		#print("player leaving the room")
		for node in room_nodes:
			if node.is_in_group("environment"):
					#unlight envvironment node
				node._toggle_visibility(false)
		#hide dynamic nodes
			if node.is_in_group("dynamic"):
				node.visible = false
		is_lighten = false
		toggle_adjacent_visibility(false)
				
func toggle_visibility(on : bool):
	#print(name,"toggle visibility")
	if !on and is_lighten or room_nodes == null:
		return
		
	for node in room_nodes:
		if node.is_in_group("environment") and node.visible!=on:
				node.visible = on
	isVisible = on
	
func toggle_adjacent_visibility(on: bool):
	#print(name," : toggle adjacent visibility")
	for area in AdjacentArea:
		#print(name," : toggle", area.name ,"visibility")
		area.toggle_visibility(on)

