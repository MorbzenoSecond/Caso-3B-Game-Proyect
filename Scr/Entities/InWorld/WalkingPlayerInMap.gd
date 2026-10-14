extends WalkingCharacterInMap

const JUMP_VELOCITY = 1
var RUN_MAX_SPEED :float= 0.2
var ACCELERATION :float= 3

var last_save_point_position : Vector3 = Vector3.ZERO
@onready var state_machine =$StateMachine

func _ready() -> void:
	super.set_sprite_frames()
	await get_tree().process_frame
	super.create_map()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func basic_movement(delta, direction):
	velocity.x = move_toward(velocity.x, direction.x * stats.RUN_MAX_SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * stats.RUN_MAX_SPEED, ACCELERATION * delta)

func teleport_last_save_point():
	global_position = last_save_point_position

func basic_movement_guided(delta):
	var ROTATION_SPEED = 4
	var next_path_pos = nav_agent.get_next_path_position()
	
	var nav_direction = global_position.direction_to(next_path_pos)
	var direction2 := (transform.basis * nav_direction).normalized()
	
	velocity.x = move_toward(velocity.x, direction2.x * RUN_MAX_SPEED, stats.ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction2.z * RUN_MAX_SPEED, stats.ACCELERATION * delta)
