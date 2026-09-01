@tool
extends Sprite3D


func _process(delta: float) -> void:
	global_position.y += sin(Time.get_ticks_msec() / 1000.0 * 1.0) * 0.02 *  delta
