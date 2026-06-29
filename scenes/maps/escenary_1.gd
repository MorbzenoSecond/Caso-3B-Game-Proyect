extends Node2D

class_name ScenaryMap

@export var scenary_fight_background : String = ""
@export var scenary_music : String = ""
@export var scenary_fight_music : String = ""
@onready var main = $"../.."

func prepare_fight_scenary(enemy_data):
	get_parent().get_parent().start_fight(enemy_data, scenary_fight_background, scenary_fight_music)

func set_camera_limits():
	var camera = $"../../MainCharacterWorld/Camera2D"
	var camera_nodes = get_node_or_null("Camera_limits")
	if camera_nodes != null:
		for marker in camera_nodes.get_children():
			if marker is Marker2D:
				if marker.name == "right_down_corner":
					camera.limit_right = marker.global_position.x
					camera.limit_bottom = marker.global_position.y
				if marker.name == "left_up_corner":
					camera.limit_left = marker.global_position.x
					camera.limit_top = marker.global_position.y
				print(marker.name + " " + str(marker.global_position))
			else:
				print("el nodo no es un marker, no se tomara en cuenta")
	else:
		print("No se encontro el nodo, la modificacion no se llevara a cabo")

func activate_room():
	modulate = Color("ffffff")
	$TileMapLayer.enabled = true
	
func deactivate_room():
	modulate = Color("ff000000")
	$TileMapLayer.enabled = false

@onready var room_name = self.name
@export var next_rooms : Array = []
@export var centered_camera : bool
@onready var conections = $conections
