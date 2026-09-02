extends Node3D

const FIGHT_SCENE = preload("res://scenes/fightSceneElements/fight_scene.tscn")
const PARTY_MEMBER = preload("res://walking_friend_in_map.tscn")

@onready var camera = $GameParty/MainCharacterWorld/pivote/Camera2D
@onready var pivote = $GameParty/MainCharacterWorld/pivote
@onready var CanvasInfo = $UI/CanvasInfo as CanvasLayer
@onready var ColorRec = $UI/CanvasInfo/ColorRect as ColorRect
@onready var MainCharacter = $GameParty/MainCharacterWorld
@onready var Dumpster = $Dumpster
@onready var WorldEnvironmentNode = $WorldEnvironment
@onready var fight_node = $NodoDePelea

var characters := {
	"players": [],
	"enemies": [],
}

var scenary_path = "res://scenes/maps/Scenaries/" + GameDataManager.data["locacion"] + ".tscn"

func _process(_delta: float) -> void:
	Node.print_orphan_nodes()
	pass
	#$WorldEnvironment.environment.sky_rotation.y += 0.1 * delta
	#$WorldEnvironment.environment.sky_rotation.x += 0.1 * delta
	#$WorldEnvironment.environment.sky_rotation.z += 0.1 * delta

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.is_pressed():
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#camera.position.y += 0.1
			#camera.position.z -= 0.01
			#camera.rotate_x(deg_to_rad(2.0))
			#
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#camera.position.y -= 0.1
			#camera.position.z += 0.01
			#camera.rotate_x(deg_to_rad(-2.0))

func setup():
	MainCharacter.global_position = GameDataManager.CurrentRoomNode.get_spawn_point()
	instanciate_party_members()

func instanciate_party_members():
	for player  in GameDataManager.data["Characters"]:
		var resoure_path =  "res://Resources/EnemiesInMap/" + player["name"] + "Resource.tres"
		if player["party_status"] == "leader":
			MainCharacter.stats = load(resoure_path)
			MainCharacter.set_sprite_frames()
			continue

		var character = PARTY_MEMBER.instantiate()
		
		character.stats = load(resoure_path)
		
		$GameParty/Followers.add_child(character)
		character.global_position  = character.get_random_nearby_position(MainCharacter.global_position)

func enter_event():
	GameDataManager.BlockedInputs = true
	$UI/UI.animation_player.play("appear")

func exit_event():
	GameDataManager.BlockedInputs = false
	$UI/UI.animation_player.play_backwards("appear")

#region Fight Manager Region
func start_fight(enemy_data, scenary_fight_background, scenary_fight_music, enemy_node):
	for i in get_tree().get_nodes_in_group("PROYECTILE"):
		i.queue_free()
	music_selector(scenary_fight_music)
	$AnimationPlayer.play("new_animation")
	
	_instanciate_fight(enemy_data, scenary_fight_background, enemy_node)
	get_tree().paused = true

func _instanciate_fight(enemy_data : Dictionary, scenary_fight_background, enemies_nodes : Array):
	var index = 1
	for player in GameDataManager.data["Characters"]:
		characters["players"].append({"id": index,  "name": player["name"], "level": player["level"], "type": "player"})
		index += 1
	
	for enemy in enemy_data["Enemies"]:
		characters["enemies"].append({"id": index,  "name": enemy["name"], "level": enemy["level"], "type": "enemy" })
		index += 1
	
	fight_node.get_child(0).charactersInBattleArray.merge(characters)
	fight_node.get_child(0).enemies_origin_nodes = enemies_nodes
	fight_node.get_child(0).global_position = MainCharacter.global_position
	fight_node.get_child(0).setup()
	pivote.reparent(fight_node.get_child(0))
	camera.projection = 1
	camera.size = 2
	await get_tree().process_frame
	
	camera.global_position = fight_node.get_child(0).get_node("Marker3D").global_position
	camera.initial_rotation.x = deg_to_rad(-40)

func finish_fight():
	get_tree().paused = false
	characters["players"].clear()
	characters["enemies"].clear()
	pivote.reparent(MainCharacter)
	music_selector($WorldNode.get_child(0).scenary_music)
	fight_node.get_child(0).global_position = Vector3(0,0,50)
	camera.position = Vector3(0, 0.579, 1.074)
	camera.projection = 0
	camera.initial_rotation.x = deg_to_rad(-20)
	$AnimationPlayer.play_backwards("new_animation")
#endregion

#region Music Manager Region
@onready var audio : AudioStreamPlayer = self.get_node_or_null("MusicAudio") as AudioStreamPlayer
var current_music: String = ""

func music_selector(_new_music : String):
	if !audio:
		print_rich("[color=red][b]Error en nodo:[/b][/color] [color=yellow]" + self.name + "[/color], nodo de audio no encontrado")
		return 
	
	if !_new_music:
		print_rich("[color=red][b]Error en nodo:[/b][/color] [color=yellow]" + self.name + "[/color], no se aceptan valores nulos")
		return 
	
	var data = GameDataManager.music.get(_new_music)
	if !data:
		print_rich("[color=red][b]Error en nodo:[/b][/color] [color=yellow]" + self.name + "[/color], musica no encontrada")
		return
	
	if current_music == _new_music:
		return
	audio.stream = load(data["Song_path"])
	current_music =_new_music
	audio.play()
#endregion
