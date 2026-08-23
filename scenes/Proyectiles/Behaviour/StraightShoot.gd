extends RigidBody3D



var direction
var Velocity : float = 1.0
var enemy_data
var node

func _process(delta: float) -> void:
	if direction != null:
		global_position += (direction * Velocity * delta) 

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		node.prepare_fight()
