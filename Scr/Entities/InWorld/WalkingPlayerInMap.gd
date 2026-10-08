extends WalkingCharacterInMap

const SPEED = 1.0
const JUMP_VELOCITY = 2
var RUN_MAX_SPEED :float= 0.8
var ACCELERATION :float= 3
var is_active: bool = true

var last_save_point_position : Vector3 = Vector3.ZERO

func _ready() -> void:
	super.set_sprite_frames()
	await get_tree().process_frame
	super.create_map()

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	super._physics_process(delta)
	
	var input_dir := Vector2.ZERO
	
	if not GameDataManager.BlockedInputs:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#super.change_resource("res://Resources/EnemiesInMap/AggroShellResource.tres")
		velocity.y = JUMP_VELOCITY
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		basic_movement(delta,direction)

func basic_movement(delta, direction):
	velocity.x = move_toward(velocity.x, direction.x * RUN_MAX_SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * RUN_MAX_SPEED, ACCELERATION * delta)

func teleport_last_save_point():
	
	global_position = last_save_point_position
