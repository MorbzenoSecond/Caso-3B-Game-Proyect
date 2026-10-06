extends State
class_name Back

func Enter():
	$"../../AnimationPlayer".play_backwards("big_collision")

func Physics_Update(delta : float):
	if parent.has_target:
		Transitioned.emit(self, "Chase")
	parent.nav_agent.target_position = parent.original_position
	parent.basic_movement(delta)
	if parent.raycast3D.is_colliding() and parent.is_on_floor():
		parent.velocity.y = parent.JUMP_VELOCITY
	
	if parent.nav_agent.distance_to_target() < 0.1:
		Transitioned.emit(self, "Normal")
