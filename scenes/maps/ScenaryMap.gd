extends Node3D

class_name ScenaryMap

@export_group("Scenary Map", "scenary_")
@export var scenary_music : String = ""
@export var scenary_environment : Environment
@export var next_rooms : Array[String] = []

@export_group("Scenary Fight", "scenary_")
@export var scenary_fight_ground : String = ""
@export var scenary_fight_music : String = ""

@onready var room_name = self.name
@onready var conections = get_node_or_null("Conections")
@onready var marcador = get_node_or_null("Elements").get_node_or_null("SavePoint")


func prepare_fight_scenary(enemy_data, enemy_nodes):
	GameDataManager.MAIN.start_fight(enemy_data, scenary_fight_ground, scenary_fight_music, enemy_nodes)

func get_spawn_point() -> Vector3 :
	if marcador:
		print_rich("[color=green][b]Hello world![/b][/color]")
		return marcador.get_node("Marker3D").global_position
	return Vector3(0,0,0)
