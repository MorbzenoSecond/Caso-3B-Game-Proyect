extends CanvasLayer

@onready var progress_bar = $loading_screen/ProgressBar
@export var next_scene_path : String = "res://scenes/General/Main.tscn"
var progress: Array[float] = []

func set_progress(value: float) -> void:
	if progress_bar:
		progress_bar.value = clamp(value, 0.0, 100.0)
		print(progress_bar.value )

func cerrar() -> void:
	queue_free()
