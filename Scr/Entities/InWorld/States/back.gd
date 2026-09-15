extends State
class_name Back

func Enter():
	$"../../AnimationPlayer".play_backwards("big_collision")

func Physics_Update(delta : float):
	if parent.has_target:
		Transitioned.emit(self, "Chase")
	parent.nav_agent.target_position = parent.original_position
	parent.basic_movement(delta)
	
	if parent.nav_agent.is_navigation_finished():
		Transitioned.emit(self, "Normal")
