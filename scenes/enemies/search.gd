extends State
class_name Search

var last_time_seen : Vector3

func Enter():
	last_time_seen =  parent.nav_agent.get_final_position()

	$Timer.start()
	$Timer2.start()

var _random_position = null
var direction

func Physics_Update(delta: float) -> void:
	if _random_position != null:
			parent.nav_agent.target_position = parent.target_pos.global_position
	parent.basic_movement(delta)
	if parent.has_target:
		Transitioned.emit(self, "Chase")

func new_random_position():
	_random_position = parent.get_random_nearby_position(last_time_seen)

func _on_timer_timeout() -> void:
	Transitioned.emit(self, "Back")

func _on_timer_2_timeout() -> void:
	new_random_position()

func Exit():
	$Timer2.stop()
	$Timer.stop()
