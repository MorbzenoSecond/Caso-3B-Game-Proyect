extends Node2D

const FIGHT_SCENE = preload("res://scenes/fightSceneElements/fight_scene.tscn")
@onready var camera = $MainCharacterWorld/Camera2D

var characters := {
	"players": {},
	"enemies": {},
}


func _ready() -> void:
	$NodoDeMundo.get_child(0).set_camera_limits(camera)

func start_fight(enemy_data, scenary_fight_background, scenary_fight_music):
	music_selector(scenary_fight_music)
	$AnimationPlayer.play("new_animation")
	instanciate_fight(enemy_data, scenary_fight_background)
	get_tree().paused = true

func instanciate_fight(enemy_data : Dictionary, scenary_fight_background):
	var scene = FIGHT_SCENE.instantiate()
	var enemigos 
	
	characters["players"]["morb"] = { "speed": 40 }
	
	for enemy in enemy_data.keys():
		enemigos = enemy
		characters["enemies"][enemy] = { "speed": enemy_data[enemy]["speed"] }
		scene.get_node("AnimatedSprite2D").play(enemy)

	
	scene.charactersInBattleArray.merge(characters)


	$NodoDePelea.add_child(scene)
	$NodoDePelea.global_position = $MainCharacterWorld.global_position
	scene.chooseBackgroundScenary(scenary_fight_background)
	if str(enemigos) == "Deviljho":
		scene.get_node("AnimatedSprite2D").offset = Vector2(80,-20)
		music_selector("boss_theme_deviljho")
	camera.reparent($NodoDePelea)
	camera.position = Vector2.ZERO

func finish_fight():
	characters["players"].clear()
	characters["enemies"].clear()
	music_selector($NodoDeMundo.get_child(0).scenary_music)
	$NodoDePelea.global_position = $MainCharacterWorld.global_position
	camera.reparent($MainCharacterWorld)
	$AnimationPlayer.play_backwards("new_animation")
	$Timer.start()

func _on_timer_timeout() -> void:
	for i in $NodoDePelea.get_children():
		i.queue_free()

#region Music Manager Region
@onready var audio : AudioStreamPlayer = self.get_node_or_null("MusicAudio") as AudioStreamPlayer

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
	
	audio.stream = load(data["Song_path"])
	audio.play()
#endregion
