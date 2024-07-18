extends EnvironmentAsset
		
enum conditions {ALLY,KEY}
var player
@export var condition : conditions

func _ready():
		player = %player
		
func _on_mouse_entered():
	match(condition):
		conditions.ALLY:
			if get_parent().has_ally:
				$Outline.visible = true
		conditions.KEY:
			if player.can_open_door():
				$Outline.visible = true
	
func _on_mouse_exited():
	if $Outline.visible:
		$Outline.visible = false
	
