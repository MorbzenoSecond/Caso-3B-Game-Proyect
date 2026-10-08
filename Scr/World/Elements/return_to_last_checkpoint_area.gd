@tool
extends Area3D

@export var ColisionShape : BoxShape3D

func _ready() -> void:
	$CollisionShape2D.shape = ColisionShape

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		body.velocity = Vector3.ZERO
		body.teleport_last_save_point()
