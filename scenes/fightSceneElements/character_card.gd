extends AnimatedSprite2D

var enemy_of_origin :Array =[]

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		$"../../..".selected_enemy(enemy_of_origin)
