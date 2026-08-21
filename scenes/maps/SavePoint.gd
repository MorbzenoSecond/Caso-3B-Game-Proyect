extends Node3D

@onready var marcador = get_node_or_null("Marker3D")

func get_spawn_point() -> Vector3 :
	if marcador:
		return marcador.global_position
	return Vector3(0,0,0)

func label_tween(label: Label):
	var tween :Tween = get_tree().create_tween()
	
	tween.tween_property(label, "modulate", Color("ffffff"),0.5)
	tween.tween_interval(2)
	tween.tween_property(label, "modulate", Color("ffffff00"),0.5)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		GameDataManager.save(GameDataManager.current_room)
		var save_label = GameDataManager.MAIN.get_node("CanvasInfo").get_node("SaveLabel")
		label_tween(save_label)
