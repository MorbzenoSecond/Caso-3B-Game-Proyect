extends Node


@onready var MAIN = get_tree().get_first_node_in_group("MAIN")
const MUSIC_PATH = "res://Resources/bibliotecas/music_manager.json"
const LOADING_SCREEN = preload("res://scenes/General/loading_screen.tscn")

var BlockedInputs : bool = false
var current_save_file = ""
var current_save_file_base_name = ""
var resume_save_file = "res://SaveFiles/resume_save_file/resume_save_file.json"
var current_room : String = "Exterior1"
var CurrentRoomNode : Node3D

var ColorTween : Tween

var music = {}
var save_files_data ={}
var data : Dictionary = {
	"locacion" : "Exterior1",
	"players" :[
		{"name": "MoshPunch", "speed": 11, "level": 1, "life": 2, "damage" : 2, "type" : "player"},
		{"name": "Player", "speed": 12, "level": 2, "life": 2, "damage" : 2, "type" : "player"},
		{"name": "Player", "speed": 11, "level": 1, "life": 2, "damage" : 2, "type" : "player"}
	]
}

func _ready() -> void:
	load_music_data()

func save(location_name : String):
	data["locacion"] = location_name
	var file = FileAccess.open(current_save_file,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	await RenderingServer.frame_post_draw
	get_window().get_texture().get_image().save_png("res://assets/ScreenShoots/" + current_save_file_base_name + ".png")
	
	save_files_data[current_save_file_base_name]["image"] = "res://assets/ScreenShoots/" + current_save_file_base_name + ".png"
	save_files_data[current_save_file_base_name]["time"] = Time.get_datetime_string_from_system()
	
	var file2 = FileAccess.open(resume_save_file,FileAccess.WRITE)
	file2.store_string(JSON.stringify(save_files_data))
	file2.close()
	
	print("guardado: " + location_name)

func load_data():
	if not FileAccess.file_exists(current_save_file):
		save("escenary1")
		await save("escenary1")
	var file = FileAccess.open(current_save_file, FileAccess.READ)
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
	"Interior1": {
		"zone" : "Interior", 
		"connections": {
			"Z1-Z2": {"target_room": "Exterior1",  "target_marker": "Z1-Z2"}
		}
	},
	"Exterior1": {
		"zone" : "Exterior", 
		"connections": {
			"Z1-Z2": {"target_room": "Interior1",  "target_marker": "Z1-Z2"},
			"E1-E2": {"target_room": "Exterior2",  "target_marker": "E1-E2"}
		}
	},
	"Exterior2": {
		"zone" : "Exterior", 
		"connections": {
			"E1-E2": {"target_room": "Exterior1",  "target_marker": "E1-E2"},
			"E2-E3": {"target_room": "Exterior3",  "target_marker": "E2-E3"}
		}
	},
	"Exterior3": {
		"zone" : "Exterior", 
		"connections": {
			"E2-E3": {"target_room": "Exterior2",  "target_marker": "E2-E3"}
		}
	}
}

func ColorTweenFunctionPart1():
	ColorTween = create_tween()
	ColorTween.tween_property(MAIN.ColorRec, "color", Color("000000"), 0.5)
	ColorTween.tween_interval(0.5)
	await ColorTween.finished

func ColorTweenFunctionPart2():
	ColorTween = create_tween()
	ColorTween.tween_property(MAIN.ColorRec, "color", Color("00000000"), 0.5)
	await ColorTween.finished

func first_connect(room_actual_node : String):
	await load_instanciate()
	await cargar_y_conectar(room_actual_node)

var load_screen_instance = null

func load_instanciate():
	if LOADING_SCREEN and not is_instance_valid(load_screen_instance):
		load_screen_instance = LOADING_SCREEN.instantiate()
		MAIN.add_child(load_screen_instance)

#optimizar a futuro
func load_current_zone(NodeNameToLoad : String = ""):
	GameDataManager.current_room = NodeNameToLoad
	var scenary_path = "res://scenes/maps/Scenaries/" + NodeNameToLoad + ".tscn"
	var scenary_path_preloaded = load(scenary_path)
	var scene = scenary_path_preloaded.instantiate()
	MAIN.get_node("WorldNode").add_child(scene)
	for child in MAIN.get_node("WorldNode").get_children():
		if child.name == NodeNameToLoad:
			CurrentRoomNode = child
			if CurrentRoomNode.scenary_fight_ground:
				print(CurrentRoomNode.scenary_fight_ground)
				var fight_scene = load(CurrentRoomNode.scenary_fight_ground).instantiate()
				MAIN.fight_node.add_child(fight_scene)

func cargar_y_conectar(room_actual_node : String):
	var time_init = Time.get_ticks_msec()
	load_current_zone(room_actual_node)

	if str(world_map[current_room]["zone"]) != str(world_map[room_actual_node]["zone"]):
		await ColorTweenFunctionPart1()
		await load_instanciate()

	var world_node = MAIN.get_node("WorldNode")
	var lista_siguientes = CurrentRoomNode.next_rooms.duplicate()
	var conexiones_room = world_map[current_room]["connections"]
	
	var total_rooms = lista_siguientes.size()
	var processed_rooms = 0

	#zonas.text = "Fragmento: " + current_room  + " Zona: "  + world_map[current_room]["zone"]
	#var zonas = get_tree().get_first_node_in_group("ZONASLABEL") as Label
	
	var pending = {}
	
	for e in lista_siguientes:
		var datos = conexiones_room[e]
		if not world_node.has_node(datos["target_room"]):
			var path = "res://scenes/maps/Scenaries/" + datos["target_room"].to_lower() + ".tscn"
			pending[e] = path
			ResourceLoader.load_threaded_request(path)
			
	for e in pending:
		var path = pending[e]
		
		while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
		
		var room_packed : PackedScene = ResourceLoader.load_threaded_get(path)
		var datos = conexiones_room[e]
		var nueva_room = room_packed.instantiate()
		
		nueva_room.name = datos["target_room"]
		world_node.add_child(nueva_room)
		
		var marker_salida = CurrentRoomNode.get_node("Conections/"+ e)
		var marker_entrada = nueva_room.get_node("Conections/"+ e)

		nueva_room.global_position = marker_salida.global_position - marker_entrada.global_position
		
		processed_rooms += 1
		if total_rooms > 0 and load_screen_instance:
			var percentaje = (float(processed_rooms) / float(total_rooms)) * 100
			load_screen_instance.set_progress(percentaje)
	var total_time = Time.get_ticks_msec() - time_init
	print_rich("[color=red][b] [DEBUG] [/b][/color] Tiempo de carga de las salas: ", total_time, " ms")

	_errase_not_linked_rooms(current_room)
	if CurrentRoomNode.scenary_environment and MAIN.WorldEnvironmentNode.environment != CurrentRoomNode.scenary_environment:
		MAIN.WorldEnvironmentNode.environment = CurrentRoomNode.scenary_environment
	MAIN.music_selector(CurrentRoomNode.scenary_music)
	if is_instance_valid(load_screen_instance):
		load_screen_instance.queue_free()
		load_screen_instance = null
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
