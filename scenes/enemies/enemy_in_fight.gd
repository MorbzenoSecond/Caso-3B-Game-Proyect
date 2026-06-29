extends Node2D

@onready var nameLabel = $Data/Name
@onready var levelLabel = $Data/Level
@onready var liveBar = $Data/ProgressBar
@onready var liveDataLabel = $Data/livedata

func set_enemy_data(enemy_data : Dictionary, enemy_name: String):
	$AnimationPlayer.play(enemy_name)
	$AnimatedSprite2D.play(enemy_name)
	levelLabel.text = "LV" + str(enemy_data[enemy_name]["level"])
	nameLabel.text = enemy_name
	
	liveBar.max_value = enemy_data[enemy_name]["life"]
	liveBar.value = enemy_data[enemy_name]["life"]
	
	liveDataLabel.text = str(enemy_data[enemy_name]["life"])+"/"+str(enemy_data[enemy_name]["life"])
