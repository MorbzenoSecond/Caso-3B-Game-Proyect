extends Node

var music = {}

const MUSIC_PATH = "res://Resources/bibliotecas/music_manager.json"
@onready var MAIN = get_tree().get_first_node_in_group("MAIN")

func _ready() -> void:
	load_music_data()
# Called when the node enters the scene tree for the first time.

func load_music_data():
	if not FileAccess.file_exists(MUSIC_PATH):
		return
	var file = FileAccess.open(MUSIC_PATH, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	if json:
		music = json
	else:
		return

#region SCENARY
var world_map = {
	"escenary1": {
		"zone" : "trees", 
		"connections": {
			"E1-E2": {"target_room": "escenary2","target_marker": "E1-E2"},
			"E1-E3": {"target_room": "escenary3", "target_marker": "E1-E3"},
			"E1-Z1": {"target_room": "zone1", "target_marker": "E1-Z1"}
		}
	},
	"escenary2": {
		"zone" : "trees", 
		"connections": {
			"E1-E2": {"target_room": "escenary1", "target_marker": "E1-E2"}
		}
	},
	"escenary3": {
		"zone" : "trees", 
		"connections": {
			"E1-E3": {"target_room": "escenary1",   "target_marker": "E1-E3"}
		}
	},
	"zone1": {
		"zone" : "house", 
		"connections": {
			"E1-Z1": {"target_room": "escenary1",  "target_marker": "E1-Z1"}
		}
	}
}

var current_room :String = "Room1"
var old_room : String

func cargar_y_conectar(room_actual_node: Node2D, room_old_node, nombre_marker_salida: Array):
	current_room = room_actual_node.name
	old_room = room_old_node
	var nombre_room_actual = room_actual_node.name
	var parent_node = get_tree().get_first_node_in_group("WorldNode")
	var zonas = get_tree().get_first_node_in_group("ZONASLABEL") as Label
	zonas.text = "Fragmento: " + nombre_room_actual  + " Zona: "  + world_map[nombre_room_actual]["zone"]
	
	
	room_actual_node.set_camera_limits()
	
	var conexiones_room = world_map[nombre_room_actual]["connections"]
	for e in nombre_marker_salida:
		var datos = conexiones_room[e]
		if parent_node.has_node(datos["target_room"]):
			continue
		var path = "res://scenes/maps/Scenaries/" + datos["target_room"].to_lower() + ".tscn"
		
		var nueva_room = load(path).instantiate()
		
		nueva_room.name = datos["target_room"]
		parent_node.call_deferred("add_child", nueva_room)
		
		
		var marker_salida = room_actual_node.get_node("conections/"+ e)
		var marker_entrada = nueva_room.get_node("conections/"+ e)
		
		
		await get_tree().process_frame
		nueva_room.global_position = marker_salida.global_position - marker_entrada.position
	if room_actual_node.centered_camera:
		center_camera(room_actual_node)
	modulate_current_room(parent_node)
	_errase_not_linked_rooms(nombre_room_actual)
	MAIN.music_selector(room_actual_node.scenary_music)



func center_camera(room_actual_node):
	var camera_node = get_tree().get_first_node_in_group("CAMERA")
	camera_node.limit_bottom = room_actual_node.get_node("Camera_limits/right_down_corner").global_position.y
	camera_node.limit_left = room_actual_node.get_node("Camera_limits/right_down_corner").global_position.x
	camera_node.limit_top = room_actual_node.get_node("Camera_limits/left_up_corner").global_position.y
	camera_node.limit_right = room_actual_node.get_node("Camera_limits/left_up_corner").global_position.x
	
	camera_node.reparent(camera_node.get_parent().get_parent())

func _errase_not_linked_rooms(nombre_room_actual):
	var rooms_to_errase = []
	var rooms_to_hide = []
	
	var zona = world_map[nombre_room_actual]["zone"]
	for i in world_map[nombre_room_actual]["connections"]:
		var salas_posibles = world_map[nombre_room_actual]["connections"][i]["target_room"]
		var sala = salas_posibles
		
		if zona != world_map[salas_posibles]["zone"]:
			rooms_to_hide.append(sala)
		
		rooms_to_errase.append(sala)
	rooms_to_errase.append(nombre_room_actual)
	var parent_node = get_tree().get_first_node_in_group("WorldNode")
	for i in parent_node.get_children():
		if !rooms_to_errase.has(i.name):
			i.queue_free()
		if rooms_to_hide.has(i.name):
			i.deactivate_room()
		else:
			i.activate_room()
		#if !parent_node.has_node(datos["target_room"]):
			#pass

func modulate_current_room(rooms_node):
	pass
	#for i in rooms_node.get_children():
		#if i.name == current_room:
			#i.modulate = Color("ffffff")
			#continue
		#i.modulate = Color("6e6e6e")
#endregion
