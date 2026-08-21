extends State
class_name Normal

var _random_position = null
var direction = Vector3(0,0,0)
var tween : Tween

func Enter():
	_random_position = null
	$Timer.start()
	tween_animation()

func Physics_Update(delta: float) -> void:
	if _random_position != null:
		parent.nav_agent.target_position = _random_position
		parent.basic_movement(delta)
	if parent.nav_agent.is_navigation_finished():
		parent.CUSTOM_RUN_MAX_SPEED = 0.0
		parent.velocity = Vector3.ZERO
		_random_position = null
	else:
		parent.CUSTOM_RUN_MAX_SPEED = parent.stats.RUN_MAX_SPEED
	if parent.has_target:
		Transitioned.emit(self, "Chase")

func tween_animation():
	tween = create_tween()
	
	tween.tween_property(parent, "rotation:y", 0, 0.5)

func Exit():
	parent.CUSTOM_RUN_MAX_SPEED = parent.stats.RUN_MAX_SPEED
	if tween.is_running():
		tween.kill()
	$Timer.stop()

func new_random_position():
	_random_position = parent.get_random_nearby_position(parent.original_position)

func _on_timer_timeout() -> void:
	new_random_position()
