@tool
extends Node3D

@onready var fight_scene = get_parent().get_parent().get_parent().get_parent()
@onready var origin_character = $"../../"

var active_cube
var animation_tween : Tween
var activated : bool = true

func _deactivate_turn():
	queue_free()

func _on_scape_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click") and activated:
		activated = false
		fight_scene.prepare_scape_options(origin_character)
		_deactivate_turn()

func _on_attack_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click") and activated:
		activated = false
		fight_scene.prepare_attack_options(origin_character)
		_deactivate_turn()

func _on_item_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click") and activated:
		activated = false
		fight_scene.prepare_item_options(origin_character)
		_deactivate_turn()

func _on_scape_area_mouse_entered() -> void:
	tween($ScapeArea/ScapeBox, 1, Vector3(1.12,1.12,1.12))

func _on_scape_area_mouse_exited() -> void:
	tween($ScapeArea/ScapeBox, 0, Vector3(1, 1, 1))

func _on_attack_area_mouse_entered() -> void:
	tween($attackArea/AttackBox, 1, Vector3(1.12,1.12,1.12))

func _on_attack_area_mouse_exited() -> void:
	tween($attackArea/AttackBox, 0, Vector3(1, 1, 1))

func _on_item_area_mouse_entered() -> void:
	tween($ItemArea/ItemBox, 1, Vector3(1.12,1.12,1.12))

func _on_item_area_mouse_exited() -> void:
	tween($ItemArea/ItemBox, 0, Vector3(1, 1, 1))

func tween(node, side, size):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	
	animation_tween.tween_property(node, "position:y", 0.08 * side, 0.15).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(node, "scale", size , 0.12).set_trans(Tween.TRANS_BOUNCE)
