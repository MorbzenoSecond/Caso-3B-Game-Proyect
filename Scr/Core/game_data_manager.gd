extends Node

@onready var MAIN = get_tree().get_first_node_in_group("MAIN")

const MUSIC_PATH = "res://Resources/DictionaryResources/music_manager.json"
const LOADING_SCREEN = preload("res://Scr/UI/Overlay/loading_screen.tscn")

var BlockedInputs : bool = false
var current_save_file = ""
var current_save_file_base_name = ""
var resume_save_file = "res://SaveFiles/ResumeSaveFile/resume_save_file.json"
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

#region Archives loader-saves Region

func save(location_name : String):
	data["locacion"] = location_name
	var file = FileAccess.open(current_save_file,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	await RenderingServer.frame_post_draw
	get_window().get_texture().get_image().save_png("res://Assets/ScreenShoots/"+ current_save_file_base_name + ".png")
	
	print(save_files_data)
	save_files_data[current_save_file_base_name]["image"] = "res://Assets/ScreenShoots/" + current_save_file_base_name + ".png"
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
#endregion

#region SCENARY
#var world_map = {
	#"escenary1": {
		#"zone" : "trees", 
		#"connections": {
			#"E1-E2": {"target_room": "escenary2","target_marker": "E1-E2"},
			#"E1-E3": {"target_room": "escenary3", "target_marker": "E1-E3"},
			#"E1-Z1": {"target_room": "zone1", "target_marker": "E1-Z1"}
		#}
	#},
	#"escenary2": {
		#"zone" : "trees", 
		#"connections": {
			#"E1-E2": {"target_room": "escenary1", "target_marker": "E1-E2"}
		#}
	#},
	#"escenary3": {
		#"zone" : "trees", 
		#"connections": {
			#"E1-E3": {"target_room": "escenary1",   "target_marker": "E1-E3"}
		#}
	#},
	#"Interior1": {
		#"zone" : "Interior", 
		#"connections": {
			#"Z1-Z2": {"target_room": "Exterior1",  "target_marker": "Z1-Z2"}
		#}
	#},
	#"Exterior1": {
		#"zone" : "Exterior", 
		#"connections": {
			#"Z1-Z2": {"target_room": "Interior1",  "target_marker": "Z1-Z2"},
			#"E1-E2": {"target_room": "Exterior2",  "target_marker": "E1-E2"}
		#}
	#},
	#"Exterior2": {
		#"zone" : "Exterior", 
		#"connections": {
			#"E1-E2": {"target_room": "Exterior1",  "target_marker": "E1-E2"},
			#"E2-E3": {"target_room": "Exterior3",  "target_marker": "E2-E3"}
		#}
	#},
	#"Exterior3": {
		#"zone" : "Exterior", 
		#"connections": {
			#"E2-E3": {"target_room": "Exterior2",  "target_marker": "E2-E3"}
		#}
	#}
#}

var world_map = {
	"Exterior":{
		"Exterior1": {
			"connections": {
				"Interior1": {"target_marker": "Z1-Z2"},
				"Exterior2": {"target_marker": "E1-E2"}
				}
			},
		"Exterior2": {
			"connections": {
				"Exterior1": {"target_marker": "E1-E2"},
				"Exterior3": {"target_marker": "E2-E3"}
				}
			},
		"Exterior3": {
			"connections": {
				"Exterior2": {"target_marker": "E2-E3"},
				"Exterior4": {"target_marker": "E3-E4"}
				}
			},
		"Exterior4": {
			"connections": {
				"Exterior2": {"target_marker": "E3-E4"}
				}
			}
		},
	"Interior":{
		"Interior1": {
			"connections": {
				"Exterior1": {"target_marker": "Z1-Z2"}
				}
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
	await ColorTween.finished

func first_connect(room_actual_node : String):
	await load_instanciate()
	await cargar_y_conectar(room_actual_node)
	_errase_not_linked_rooms()

var load_screen_instance = null

func get_scene_path(room_name: String) -> String:
	return "res://Scr/World/Maps/" + room_name + ".tscn"

func load_instanciate():
	if LOADING_SCREEN and not is_instance_valid(load_screen_instance):
		load_screen_instance = LOADING_SCREEN.instantiate()
		MAIN.add_child(load_screen_instance)

#optimizar a futuro
func load_current_zone(node_name_to_load: String) -> void:
	GameDataManager.current_room = node_name_to_load
	var scene_path = get_scene_path(node_name_to_load)
	
	if ResourceLoader.exists(scene_path):
		var scenary_path_preloaded = load(scene_path)
		var scene = scenary_path_preloaded.instantiate()
		scene.name = node_name_to_load
		MAIN.get_node("WorldNode").add_child(scene)
		CurrentRoomNode = scene

		if "scenary_fight_ground" in CurrentRoomNode and CurrentRoomNode.scenary_fight_ground:
			if FileAccess.file_exists(CurrentRoomNode.scenary_fight_ground):
				var fight_scene = load(CurrentRoomNode.scenary_fight_ground).instantiate()
				MAIN.fight_node.add_child(fight_scene)
				fight_scene.position.y = 20
	else:
		push_error("Scene file not found: " + scene_path)

func get_zone_of_room(room_name: String) -> String:
	for zone_name in world_map.keys():
		if world_map[zone_name].has(room_name):
			return zone_name
	return ""

func cargar_y_conectar(room_actual_node: String, zone_actual_node: String = "Exterior") -> void:
	var time_init = Time.get_ticks_msec()
	var world_node = MAIN.get_node("WorldNode")

	if not world_node.has_node(room_actual_node):
		load_current_zone(room_actual_node)
	else:
		CurrentRoomNode = world_node.get_node(room_actual_node)
		GameDataManager.current_room = room_actual_node

	if not world_map.has(zone_actual_node):
		push_error("Zona no encontrada en world_map: " + zone_actual_node)
		return

	var lista_siguientes = world_map[zone_actual_node]
	var pending: Dictionary = {}

	for room_name in lista_siguientes.keys():
		if not world_node.has_node(room_name):
			var path = get_scene_path(room_name)
			pending[room_name] = path
			ResourceLoader.load_threaded_request(path)

	var total_to_load = pending.size()
	var processed_count = 0

	for room_name in pending.keys():
		var path = pending[room_name]

		while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame

		if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
			var room_packed: PackedScene = ResourceLoader.load_threaded_get(path)
			var nueva_room = room_packed.instantiate()
			nueva_room.name = room_name
			world_node.add_child(nueva_room)

		processed_count += 1
		if total_to_load > 0 and load_screen_instance and load_screen_instance.has_method("set_progress"):
			var percentage = (float(processed_count) / float(total_to_load)) * 100.0
			load_screen_instance.set_progress(percentage)

	_posicionar_salas_zona(room_actual_node, world_node)

	var total_time = Time.get_ticks_msec() - time_init
	print_rich("[color=red][b] [DEBUG] [/b][/color] Tiempo de carga de las salas: ", total_time, " ms")

	if is_instance_valid(CurrentRoomNode):
		if "scenary_environment" in CurrentRoomNode and CurrentRoomNode.scenary_environment:
			if MAIN.WorldEnvironmentNode.environment != CurrentRoomNode.scenary_environment:
				MAIN.WorldEnvironmentNode.environment = CurrentRoomNode.scenary_environment
		if "scenary_music" in CurrentRoomNode and CurrentRoomNode.scenary_music:
			MAIN.music_selector(CurrentRoomNode.scenary_music)

	if is_instance_valid(load_screen_instance):
		load_screen_instance.queue_free()
		load_screen_instance = null

func _posicionar_salas_zona(root_room_name: String, world_node: Node) -> void:
	var posicionadas = [root_room_name]
	var cola = [root_room_name]

	while cola.size() > 0:
		var actual = cola.pop_front()
		var nodo_actual = world_node.get_node_or_null(actual)
		if not nodo_actual:
			continue

		var zona_actual = get_zone_of_room(actual)
		if zona_actual == "" or not world_map[zona_actual].has(actual):
			continue

		var conexiones = world_map[zona_actual][actual].get("connections", {})
		for sala_destino in conexiones.keys():
			if sala_destino in posicionadas:
				continue

			var nodo_destino = world_node.get_node_or_null(sala_destino)
			if nodo_destino:
				var marker_name = conexiones[sala_destino]["target_marker"]
				var marker_salida = nodo_actual.get_node_or_null("Conections/" + marker_name)
				var marker_entrada = nodo_destino.get_node_or_null("Conections/" + marker_name)

				if marker_salida and marker_entrada:
					var local_offset = marker_entrada.global_position - nodo_destino.global_position
					nodo_destino.global_position = marker_salida.global_position - local_offset

				posicionadas.append(sala_destino)
				cola.append(sala_destino)

func _errase_not_linked_rooms() -> void:
	var world_node = MAIN.get_node("WorldNode")
	var room_actual = GameDataManager.current_room
	var zona_actual = get_zone_of_room(room_actual)

	if zona_actual == "" or not world_map[zona_actual].has(room_actual):
		return

	var conexiones = world_map[zona_actual][room_actual].get("connections", {})

	for child in world_node.get_children():
		if child.name == room_actual or conexiones.has(child.name):
			child.visible = true
		else:
			child.visible = false
#endregion
