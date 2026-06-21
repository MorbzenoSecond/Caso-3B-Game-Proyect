extends Node

var music = {}

const MUSIC_PATH = "res://Resources/bibliotecas/music_manager.json"

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
	print(json)
