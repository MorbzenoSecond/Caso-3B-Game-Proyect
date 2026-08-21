extends Node3D

class_name ScenaryMap

@export var scenary_fight_background : String = ""
@export var scenary_music : String = ""
@export var scenary_fight_music : String = ""
@export var next_rooms : Array[String] = []


func prepare_fight_scenary(enemy_data, enemy_node):
	get_parent().get_parent().start_fight(enemy_data, scenary_fight_background, scenary_fight_music, enemy_node)

@onready var room_name = self.name
@onready var conections = get_node_or_null("Conections")
@onready var marcador = get_node_or_null("Elements").get_node_or_null("SavePoint")

func get_spawn_point() -> Vector3 :
	if marcador:
		print_rich("[color=green][b]Hello world![/b][/color]") # Prints "Hello world!", in green with a bold font.
		return marcador.get_node("Marker3D").global_position
	return Vector3(0,0,0)
