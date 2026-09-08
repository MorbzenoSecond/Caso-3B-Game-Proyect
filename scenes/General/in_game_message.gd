extends Node3D

@onready var point = $Label3D as Label3D

func setup(points, inital_color : Color = Color("ffffff")):
	fade_in_fade_out(inital_color)
	point.text = points

var tween : Tween

func fade_in_fade_out(inital_color : Color = Color("ffffff")):
	tween = create_tween()
	tween.tween_property(point, "modulate", inital_color, 0.5)
	tween.parallel().tween_property(point, "position", position + Vector3(0, 1, 1), 3)
	tween.tween_property(point, "modulate", Color("ffffff00"), 0.5)
	tween.parallel().tween_property(point, "position", position + Vector3(0, 3, 2), 0.5)
	tween.tween_callback(queue_free)
