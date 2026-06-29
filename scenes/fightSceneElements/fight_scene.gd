extends Node2D

var turnArray : = []
var charactersInBattleArray : Dictionary = {}
var turnDictionary : = {}


func _ready() -> void:
	$Icon.play("default")
	set_keys()
	enterExitAnimation()
	$AnimationPlayer.play("ingrese")
	turnArray.clear()
	turns()         

func finish_fight():
	$AnimationPlayer.play_backwards("ingrese")
	get_parent().get_parent().finish_fight()
	enterExitAnimation()
	$Timer.start()      

var current_player_dist = 0
var current_enemy_dist = 0
var player_data 
var enemy_data
var player_name
var enemy_name

func set_keys():
	for key in charactersInBattleArray.keys():
		if key == "players":
			for player in charactersInBattleArray[key]:
				player_name = player
				player_data = charactersInBattleArray[key][player]
		if key == "enemies":
			for enemy in charactersInBattleArray[key]:
				$enemyInFight.set_enemy_data(charactersInBattleArray[key], enemy)
				enemy_name = enemy
				enemy_data = charactersInBattleArray[key][enemy]
	
	nextTurns()

func nextTurns():
	var turn_threshold = 100

	print("Fight | original enemy speed: " + str(current_enemy_dist) + ", original player speed: " + str(current_player_dist))
	print("-----------------------------------------------------------------------------------------------------------------")
	
	while (turnArray.size() < 6):
		current_player_dist += player_data["speed"]
		current_enemy_dist += enemy_data["speed"]
		
		while (current_player_dist >= turn_threshold or current_enemy_dist >= turn_threshold) and turnArray.size() < 6:
			if current_player_dist >= current_enemy_dist:
				turnArray.append("player_turn")
				current_player_dist -= turn_threshold 
				print_rich("Turno %d: [color=green][b]JUGADOR[/b][/color]" % turnArray.size())
			else:
				turnArray.append("enemy_turn")
				current_enemy_dist -= turn_threshold
				print_rich("Turno %d: [color=red][b]ENEMIGO[/b][/color]" % turnArray.size())
				
	print("-------------------------------------------------------------------------")

func turns():
	if turnArray.size() < 6:
		nextTurns() 
		turn()
	
	var turn = turnArray.pop_front()
	
	if turn == "enemy_turn":
		enemy_turn()
	elif turn == "player_turn": 
		player_turn()
	else:
		print_rich("[color=yellow]Aviso:[/color] Cola de turnos vacía.")

func chooseBackgroundScenary(scenary_fight_background):
	if scenary_fight_background == "lol":
		$ColorRect3.self_modulate = Color("61bc58")

func _on_timer_timeout() -> void:
	get_tree().paused = false

func turn():
	var i = 0
	for node in $Node2D.get_children():
		if node is AnimatedSprite2D:
			if i < turnArray.size() and turnArray[i] == "player_turn": 
				node.animation = "player"
				node.get_node("AnimatedSprite2D").animation = "player"
				
				if node.material:
					var unique_material = node.get_node("AnimatedSprite2D").material.duplicate() as ShaderMaterial
					unique_material.set_shader_parameter("progress", 0.845)
					unique_material.set_shader_parameter("progress2", 0.845)
					node.material = unique_material
			else:
				node.animation = enemy_name
				node.get_node("AnimatedSprite2D").animation = enemy_name
			i += 1

func enterExitAnimation():
	var tween := create_tween()
	$BackBufferCopy/ColorRect.material.set_shader_parameter("progress", 0.7)  
	$BackBufferCopy/ColorRect.material.set_shader_parameter("pixel_count", 264.0) 

	tween.tween_property($BackBufferCopy/ColorRect.material, "shader_parameter/progress", 0, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property($BackBufferCopy/ColorRect.material, "shader_parameter/pixel_count", 16.0, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

func enemy_turn():
	var tween := create_tween()
	tween.tween_property($enemyInFight, "modulate", Color("000000"), 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property($enemyInFight, "modulate", Color("ffffff"), 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(turns)


func player_turn():
	$Icon/playerInterface._activate_turn()
