extends State
class_name InCutscene

func Physics_Update(delta: float) -> void:
	parent._physics_process(delta)
	if parent.target_pos:
		parent.nav_agent.target_position = parent.target_pos.global_position
		parent.basic_movement_guided(delta)
		if parent.nav_agent.distance_to_target() < 0.1:
			parent.CUSTOM_RUN_MAX_SPEED = 0.0
			parent.velocity = Vector3.ZERO
			return
		parent.CUSTOM_RUN_MAX_SPEED = parent.stats.RUN_MAX_SPEED 
