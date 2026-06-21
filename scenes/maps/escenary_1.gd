extends Node2D

@export var scenary_fight_background : String = ""
@export var scenary_music : String = ""
@export var scenary_fight_music : String = ""
@onready var main = $"../.."

func _ready() -> void:
	main.music_selector(scenary_music)

func prepare_fight_scenary(enemy_data):
	get_parent().get_parent().start_fight(enemy_data, scenary_fight_background, scenary_fight_music)

func set_camera_limits(camera):
	var camera_nodes = get_node_or_null("Camera_limits")
	if camera_nodes != null:
		for marker in camera_nodes.get_children():
			if marker is Marker2D:
				if marker.name == "right_down_corner":
					camera.limit_right = marker.position.x
					camera.limit_bottom = marker.position.y
				if marker.name == "left_up_corner":
					camera.limit_left = marker.position.x
					camera.limit_top = marker.position.y
				print(marker.name + " " + str(marker.position))
			else:
				print("el nodo no es un marker, no se tomara en cuenta")
	else:
		print("No se encontro el nodo, la modificacion no se llevara a cabo")
