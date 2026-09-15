extends WalkingCharacterInMap
class_name WalkingNPCInMap

@export var Stationary : bool = false
@export var event_data : EventsResource

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var CUSTOM_RUN_MAX_SPEED = stats.RUN_MAX_SPEED

var direction : Vector3 = Vector3(0,0,0)
var player_is_in : bool = false

func get_random_nearby_position(positionType: Vector3):
	var random_x = positionType.x + randf_range( -0.75, 0.75)
	var random_y = positionType.y + randf_range( -0.75, 0.75)
	var random_z = positionType.z + randf_range( -0.75, 0.75)
	return Vector3(random_x, random_y, random_z)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func basic_movement(delta):
	var ROTATION_SPEED = 4
	var next_path_pos = nav_agent.get_next_path_position()
	
	direction = global_position.direction_to(next_path_pos)
	var direction2 := (transform.basis * direction).normalized()
	
	velocity.x = move_toward(velocity.x, direction2.x * CUSTOM_RUN_MAX_SPEED, stats.ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction2.z * CUSTOM_RUN_MAX_SPEED, stats.ACCELERATION * delta)

	var target_rotation = direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.MODEL_BOTTOM)
	if abs(target_rotation - rotation.y) >deg_to_rad(60):
		ROTATION_SPEED = 20
	$RotableObjects.rotation.y = move_toward($RotableObjects.rotation.y, target_rotation, delta * ROTATION_SPEED)
