extends Node3D

@onready var point = $Label3D as Label3D

func setup(points):
	fade_in_fade_out()
	point.text = str(points)
	print("existo")

var tween : Tween

func fade_in_fade_out():
	tween = get_tree().create_tween()
	tween.tween_property(point, "modulate", Color("ffffff"), 0.5)
	tween.parallel().tween_property(point, "position", position + Vector3(0, 1, 1), 1)
	tween.tween_property(point, "modulate", Color("ffffff00"), 0.5)
	tween.parallel().tween_property(point, "position", position + Vector3(0, 3, 2), 0.5)
	#tween.parallel().tween_property(self, "scale", Vector2(0, 8), 0.5)

func _on_timer_timeout() -> void:
	queue_free()
