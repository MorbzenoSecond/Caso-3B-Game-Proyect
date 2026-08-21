@tool
extends Node3D

var active_cube

func _deactivate_turn():
	queue_free()

func _attack():
	for enemy in get_parent().get_parent().get_parent().get_parent().selected_enemies:
		$"../../".basic_attack(enemy)

func _on_scape_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		print(get_parent().get_parent().get_parent().get_parent().name)
		get_parent().get_parent().get_parent().get_parent().finish_fight()
		_deactivate_turn()

func _on_attack_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		print("Area INPUT")
		_attack()
		_deactivate_turn()

func _on_item_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		_deactivate_turn()

func _on_scape_area_mouse_entered() -> void:
	tween($ScapeArea/ScapeBox, 1, Vector3(0.12,0.12,0.12))

func _on_scape_area_mouse_exited() -> void:
	tween($ScapeArea/ScapeBox, 0, Vector3(0.1, 0.1, 0.1))

func _on_attack_area_mouse_entered() -> void:
	tween($attackArea/AttackBox, 1, Vector3(0.12,0.12,0.12))

func _on_attack_area_mouse_exited() -> void:
	tween($attackArea/AttackBox, 0, Vector3(0.1, 0.1, 0.1))

func _on_item_area_mouse_entered() -> void:
	tween($ItemArea/ItemBox, 1, Vector3(0.12,0.12,0.12))

func _on_item_area_mouse_exited() -> void:
	tween($ItemArea/ItemBox, 0, Vector3(0.1, 0.1, 0.1))


var animation_tween : Tween

func tween(node, side, size):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	
	animation_tween.tween_property(node, "position:y", 0.08 * side, 0.15).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(node, "scale", size , 0.12).set_trans(Tween.TRANS_BOUNCE)
