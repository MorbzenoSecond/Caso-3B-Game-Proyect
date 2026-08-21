extends Node

var music = {}

var data : Dictionary = {
	"locacion" : "escenary1",
	"players" :[
		{"name": "MoshPunch", "speed": 11, "level": 1, "life": 2, "damage" : 2, "type" : "player"},
		{"name": "Player", "speed": 12, "level": 2, "life": 2, "damage" : 2, "type" : "player"},
		{"name": "Player", "speed": 11, "level": 1, "life": 2, "damage" : 2, "type" : "player"}
	]
}

var BlockedInputs : bool = false

const MUSIC_PATH = "res://Resources/bibliotecas/music_manager.json"
@onready var MAIN = get_tree().get_first_node_in_group("MAIN")

func _ready() -> void:
	load_music_data()

const SAVE_PATH = "res://save_file.json"

func save(location_name : String):
	data["locacion"] = location_name
	var file = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("guardado: " + location_name)

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		save("escenary1")
		await save("escenary1")
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	if json:
		data = json
	else:
		return

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

func create_dialogue(NewDialogue : Resource):
	if !NewDialogue:
		print(self.name + " Este personaje No cuenta con Dialogos activos")
		return
	if BlockedInputs:
		print(self.name + " Ya hay un dialogo activo")
		return
	BlockedInputs = true
	DialogueManager.show_example_dialogue_balloon(NewDialogue, "start")
	await DialogueManager.dialogue_ended
	BlockedInputs = false

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
		"zone" : "trees", 
		"connections": {
			#"E1-Z1": {"target_room": "escenary1",  "target_marker": "E1-Z1"},
			"Z1-Z2": {"target_room": "zone2",  "target_marker": "Z1-Z2"}
		}
	},
	"zone2": {
		"zone" : "house", 
		"connections": {
			"Z1-Z2": {"target_room": "zone1",  "target_marker": "Z1-Z2"}
		}
	}
}

var current_room : String = ""
var CurrentRoomNode : Node3D

var ColorTween : Tween

func ColorTweenFunctionPart1():
	ColorTween = create_tween()
	ColorTween.tween_property(MAIN.ColorRec, "color", Color("000000"), 0.5)
	ColorTween.tween_interval(0.5)
	await ColorTween.finished

func ColorTweenFunctionPart2():
	ColorTween = create_tween()
	ColorTween.tween_property(MAIN.ColorRec, "color", Color("00000000"), 0.5)
	await ColorTween.finished

func cargar_y_conectar(room_actual_node : String):
	if str(world_map[current_room]["zone"]) != str(world_map[room_actual_node]["zone"]):
		await ColorTweenFunctionPart1()

	MAIN.load_current_zone(room_actual_node)
	for children in MAIN.get_node("WorldNode").get_children():
		if children.name == room_actual_node:
			CurrentRoomNode = children

	var parent_node = get_tree().get_first_node_in_group("WorldNode")
	var zonas = get_tree().get_first_node_in_group("ZONASLABEL") as Label
	zonas.text = "Fragmento: " + current_room  + " Zona: "  + world_map[current_room]["zone"]
	
	var nombre_marker_salida = "res://scenes/maps/Scenaries/" + current_room.to_lower() + ".tscn"
	var nueva_room2 = load(nombre_marker_salida).instantiate()
	
	var conexiones_room = world_map[current_room]["connections"]
	for e in nueva_room2.next_rooms:
		var datos = conexiones_room[e]
		if parent_node.has_node(datos["target_room"]):
			continue
		var path = "res://scenes/maps/Scenaries/" + datos["target_room"].to_lower() + ".tscn"
		
		var nueva_room = load(path).instantiate()
		
		nueva_room.name = datos["target_room"]
		parent_node.call_deferred("add_child", nueva_room)
		
		var marker_salida = CurrentRoomNode.get_node("Conections/"+ e)
		var marker_entrada = nueva_room.get_node("Conections/"+ e)
		
		await get_tree().process_frame
		nueva_room.global_position = marker_salida.global_position - marker_entrada.position
	_errase_not_linked_rooms(current_room)
	MAIN.music_selector(CurrentRoomNode.scenary_music)
	ColorTweenFunctionPart2()
	

func _errase_not_linked_rooms(ActualRoom):
	var rooms_to_errase = []
	var rooms_to_hide = []

	var zona = world_map[ActualRoom]["zone"]
	for i in world_map[ActualRoom]["connections"]:
		var salas_posibles = world_map[ActualRoom]["connections"][i]["target_room"]
		var sala = salas_posibles

		if zona != world_map[salas_posibles]["zone"]:
			rooms_to_hide.append(sala)

		rooms_to_errase.append(sala)
	rooms_to_errase.append(ActualRoom)
	var parent_node = get_tree().get_first_node_in_group("WorldNode")
	for i in parent_node.get_children():
		if !rooms_to_errase.has(i.name):
			i.queue_free()
		if rooms_to_hide.has(i.name):
			i.queue_free()
		else :
			pass
#endregion
