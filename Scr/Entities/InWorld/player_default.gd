extends State
class_name Default

func Physics_Update(delta: float) -> void:
	parent._physics_process(delta)
	
	var input_dir := Vector2.ZERO
	
	if not GameDataManager.BlockedInputs:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_just_pressed("ui_accept") and parent.is_on_floor():
		parent.velocity.y = parent.JUMP_VELOCITY
	
	var direction : Vector3 = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	print(parent.velocity)
	if direction:
		
		parent.velocity.x = direction.x * parent.stats.RUN_MAX_SPEED
		parent.velocity.z = direction.z * parent.stats.RUN_MAX_SPEED
	else:
		parent.basic_movement(delta,direction)

func Exit():
	parent.velocity = Vector3.ZERO
