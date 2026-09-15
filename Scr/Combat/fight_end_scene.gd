extends Node3D

func _on_timer_timeout() -> void:
	get_parent().finish_fight()
