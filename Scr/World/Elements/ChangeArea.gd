@tool
extends Area3D

@export var new_room : String = ""
@export var new_room_zone : String = "Exterior"
@export var ColisionShape : BoxShape3D

func _ready() -> void:
	$CollisionShape2D.shape = ColisionShape

func _on_body_entered(body: Node3D) -> void:
	if get_parent().get_parent().name == GameDataManager.current_room and body.is_in_group("PLAYER"):
		await GameDataManager.cargar_y_conectar(new_room, new_room_zone)
		GameDataManager._errase_not_linked_rooms()
