@tool
extends Area3D

@export var new_room : String = ""
@export var new_room_zone : String = "Exterior"
@export var ColisionShape : BoxShape3D

@onready var scenary_node = $"../.."

func _ready() -> void:
	$CollisionShape2D.shape = ColisionShape

func _on_body_entered(body: Node3D) -> void:
	if get_parent().get_parent().name == GameDataManager.current_room:
		if body.is_in_group("PLAYER"):
			await GameDataManager.cargar_y_conectar(new_room, new_room_zone)
			GameDataManager._errase_not_linked_rooms()
	
	#print(new_room)
	#print(body.get_parent().get_parent().name)
	
	if new_room != body.get_parent().get_parent().name:
		if body is WalkingEnemyInMap:
			change_parent(body, new_room)
			print(body.name)

func change_parent(body : CharacterBody3D,new_room_to_reparent : String):
	body.reparent(GameDataManager.MAIN.get_node("WorldNode").get_node(str(new_room_to_reparent)).get_node("Enemies"))
