extends State
class_name Chase

var booleano = true

func Enter():
	for child in get_children():
		child.start()
	$"../../AudioStreamPlayer3D".play()
	
	$"../../AnimationPlayer".play("big_collision")

func Physics_Update(delta : float):
	if !parent.has_target:
		
		Transitioned.emit(self, "Search")
	parent.nav_agent.target_position = parent.target_pos.global_position
	parent.basic_movement(delta)

func Exit():
	for node in get_children():
		if node is Timer:
			node.stop()

func _on_special_action_timeout(Action: Resource ) -> void:
	Action.execute(parent)
