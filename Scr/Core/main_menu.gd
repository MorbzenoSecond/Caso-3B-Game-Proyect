extends Control

const BUTTON = preload("res://Scr/UI/Components/button.tscn")

var resume_save_file = "res://SaveFiles/ResumeSaveFile/resume_save_file.json"

func _ready() -> void:
	await load_resume()
	get_all_save_files()

func load_resume():
	if not FileAccess.file_exists(resume_save_file):
		# funcion para crear en caso de no existir  despues
		return
	var file = FileAccess.open(resume_save_file, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	if json:
		GameDataManager.save_files_data = json
		
	else:
		return

func get_all_save_files():
	var save_files = DirAccess.get_files_at("res://SaveFiles/")
	for file in save_files:
		if file.get_extension() == "json":
			var button = BUTTON.instantiate()
			$Control/ScrollContainer/VBoxContainer.add_child(button)
			
			if GameDataManager.save_files_data.has(file.get_basename()):
				
				if FileAccess.file_exists(GameDataManager.save_files_data[file.get_basename()]["image"]):
					button.button_control.get_node("TextureRect").texture = load(GameDataManager.save_files_data[file.get_basename()]["image"])
				
			#button.time_label.text = GameDataManager.save_files_data[file.get_basename()]["time"]
			button.button_control.get_node("Label").text = file.get_basename()
			button.game_file = "res://SaveFiles/" + file.get_basename() + ".json"

func start_game():
	await GameDataManager.load_data()
	await GameDataManager.first_connect(GameDataManager.data["locacion"])
	visible = false
	GameDataManager.MAIN.setup()
