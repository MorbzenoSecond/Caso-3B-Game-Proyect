extends Area2D

func _process(delta: float) -> void:
	var  direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y =Input.get_axis("ui_up", "ui_down")
	if direction != Vector2.ZERO:
		global_position += direction.normalized() * 1000 * delta
