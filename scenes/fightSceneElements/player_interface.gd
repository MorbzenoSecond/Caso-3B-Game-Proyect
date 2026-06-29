extends Node2D

func _on_scape_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		get_parent().get_parent().finish_fight()
		$ScapeArea/CollisionShape2D.disabled = true
		_deactivate_turn()

func _on_attack_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("attack INPUT")
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		_deactivate_turn()

func _activate_turn():
	for node in get_children():
		if node is Area2D:
			node.get_node("CollisionShape2D").disabled = false
	PhysicsServer2D.set_active(true) 
	Input.flush_buffered_events()

func _deactivate_turn():
	for node in get_children():
		if node is Area2D:
			node.get_node("CollisionShape2D").disabled = true
	$"../..".turns()

func _on_item_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("Area INPUT")
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		_deactivate_turn()
