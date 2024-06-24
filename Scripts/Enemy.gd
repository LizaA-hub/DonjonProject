extends CharacterBody3D
var FollowTarget = false
var TargetBody
@onready var navigationAgent: NavigationAgent3D = get_node("NavigationAgent3D")
var speed = 200
enum{IDLE,NEW_DIR,MOVE}
var currentState = IDLE
var direction = Vector3.RIGHT
var newPosition
@export var MaxDistance : float = 10

func _physics_process(delta):
	if(FollowTarget):
		navigationAgent.target_position = TargetBody.global_position
		
		if navigationAgent.is_navigation_finished():
			return
		
		var nextPathPosition: Vector3 = navigationAgent.get_next_path_position()
		var currentAgenPosition: Vector3 = global_position
		var newVelocity : Vector3 = (nextPathPosition - currentAgenPosition).normalized() * speed * delta
		
		look_at(TargetBody.global_position)
		if(navigationAgent.avoidance_enabled):
			navigationAgent.set_velocity(newVelocity)
		else:
			_on_navigation_agent_3d_velocity_computed(newVelocity)
	else:
		match currentState:
			IDLE:
				pass
			NEW_DIR:
				direction = choose([Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK])
				#_on_timer_timeout()
			MOVE:
				newPosition = position + direction * speed * delta
				
				if(abs(newPosition.x) > MaxDistance or abs(newPosition.z) > MaxDistance):
					_on_timer_timeout()
					#print(newPosition)
					return
			
				velocity = direction * speed * delta
				look_at(global_position+velocity)
				move_and_slide()

func _on_trigger_area_body_entered(body):
	if(body.is_in_group("EnemyTarget") and !FollowTarget):
		#TargetBody = body
		#FollowTarget = true
		ShowBubble()


func _on_trigger_area_body_exited(body):
	if(body == TargetBody) :
		FollowTarget = false
		if(navigationAgent.avoidance_enabled):
			navigationAgent.set_velocity(Vector3.ZERO)
		else:
			_on_navigation_agent_3d_velocity_computed(Vector3.ZERO)


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
		
	move_and_slide()

func ShowBubble():
	var tween = create_tween()
	tween.tween_property($bubble,"visible",true,0.1)
	$bubble.DisplayEmote("Surprise")
	tween.tween_property($bubble,"visible",false,3)

func choose(array):
	array.shuffle()
	return array.front()


func _on_timer_timeout():
	$Timer.wait_time = choose([0.5,1,1.5])
	currentState = choose([IDLE,NEW_DIR,MOVE])
