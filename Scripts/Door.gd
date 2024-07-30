extends Node3D
		
enum conditions {ALLY,KEY,NONE}
var player
@export var condition : conditions
var animator
var parent

func _ready():
		player = %player
		animator = $AnimationPlayer
		parent = get_parent()
		if parent == null:
			print(name, " : parent not found")

		
func _on_mouse_entered():
	$door/Outline.visible = check_condition()

	
func _on_mouse_exited():
	if $door/Outline.visible:
		$door/Outline.visible = false
	
func interact():
	if check_condition():
		match(condition):
			conditions.KEY:
				player.remove_item(Item.types.KEY)
				animator.play("DoorOpening")
				%AudioManager.play("Rumble")
			conditions.ALLY:
				parent.start_door_animation()
	else:
		player.ShowBubble("Question",2)
	#else show dialogue player

func _on_door_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.is_pressed():
				player.try_interact(self)

func check_condition() -> bool:
	match(condition):
		conditions.ALLY:
			if parent.has_ally:
				return true
		conditions.KEY:
			if player.can_open_door():
				return true
	return false

func _on_animation_player_animation_finished(_anim_name):
	move_down()
	
func move_down() -> void:
	var open_position = global_position
	open_position.y = -10
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",open_position,1)
	await tween.finished
	%AudioManager.stop()
