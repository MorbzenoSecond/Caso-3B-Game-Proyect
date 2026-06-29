extends Area2D

@export var new_room : String = ""

func _on_body_entered(body: Node2D) -> void:
	if get_parent().name == GameDataManager.current_room and body.is_in_group("PLAYER"):
		GameDataManager.cargar_y_conectar(get_node("../../" + new_room), get_parent().name, get_node("../../" + new_room).next_rooms)
