extends Node2D

var enemy_of_origin
@onready var TypeCard = $TypeCard
@onready var CharacterCard = $TypeCard/CharacterCard
@onready var original_position_y = $TypeCard.position.y

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		enemy_of_origin.select_body_part()

var animation_tween : Tween

func tween(side, size):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	
	animation_tween.tween_property(TypeCard, "position:y", original_position_y + side, 0.15).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(TypeCard, "scale", size , 0.12).set_trans(Tween.TRANS_BOUNCE)

func _on_area_2d_mouse_entered() -> void:
	if !enemy_of_origin.animated_sprite_3D.is_in_group("SELECTARROW"):
		enemy_of_origin.above_body_part()
	tween(-6, Vector2(1.2, 1.2))

func _on_area_2d_mouse_exited() -> void:
	if !enemy_of_origin.animated_sprite_3D.is_in_group("SELECTARROW"):
		enemy_of_origin.above_body_part_quit()
	tween(0, Vector2(1, 1))
