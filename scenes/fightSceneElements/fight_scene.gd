extends Node3D

var turnArray : Array = []
var charactersInBattleArray : Dictionary = {}
var turnDictionary : = {}
var enemies_origin_nodes : Array
var combatientes: Array = []
@export var battle_paused : bool = false

const ENEMY_SCENE = preload("res://scenes/enemies/enemy_in_fight.tscn")
const END_FIGHT_SCENE = preload("res://scenes/fightSceneElements/fight_end_scene.tscn")

func _ready() -> void:
	await set_keys()
	await enterExitAnimation()
	$AnimationPlayer.play("ingrese")
	await get_tree().process_frame
	await turns()
	select_all_enemies()

func finish_fight():
	$AnimationPlayer.play_backwards("ingrese")
	get_parent().get_parent().finish_fight()
	enterExitAnimation()
	$Timer.start()      

func set_keys():
	for key in charactersInBattleArray.keys():
		if key == "players":
			var posible_positions_characters = $CharacterPosiblePositions.get_children()
			for player in charactersInBattleArray[key]:
				var character_to_instanciate = ENEMY_SCENE.instantiate()
				$Characters.add_child(character_to_instanciate)
				character_to_instanciate.global_position = Posible_spawn_positions(posible_positions_characters)
				await character_to_instanciate.setup(player)
				combatientes.append({
					"id": combatientes.size() + 1,
					"name": player["name"],
					"data": player,
					"type": "player",
					"able_to_fight" : true,
					"current_dist": 0.0,
					"speed": character_to_instanciate.true_speed,
					"node": character_to_instanciate,
					"main_body_node" : character_to_instanciate.main_body_part
				})
				
		if key == "enemies":
			var posible_positions_enemies = $EnemyPosiblePositions.get_children()
			for enemy in charactersInBattleArray[key]:
				var character_to_instanciate = ENEMY_SCENE.instantiate()
				$Enemies.add_child(character_to_instanciate)
				character_to_instanciate.global_position = Posible_spawn_positions(posible_positions_enemies)
				await character_to_instanciate.setup(enemy)
				combatientes.append({
					"id": combatientes.size() + 1,
					"name": enemy["name"],
					"data": enemy,
					"type": "enemy",
					"able_to_fight" : true,
					"current_dist": 0.0,
					"speed": character_to_instanciate.true_speed,
					"node": character_to_instanciate,
					"main_body_node" : character_to_instanciate.main_body_part
				})
				

func nextTurns():
	var turn_threshold: float = 100.0

	var hay_combatientes_activos: bool = false
	for combatiente in combatientes:
		if combatiente.get("able_to_fight", true) and combatiente.get("speed", 0.0) > 0.0:
			hay_combatientes_activos = true
			break

	if not hay_combatientes_activos:
		print_rich("[color=yellow]Aviso:[/color] No hay combatientes activos con velocidad mayor a 0.")
		return

	while turnArray.size() < 5:
		for combatiente in combatientes:
			if combatiente.get("able_to_fight", true):
				combatiente["current_dist"] += combatiente["speed"]

		while turnArray.size() < 5:
			var combatientes_listo = []
			
			for combatiente in combatientes:
				if combatiente.get("able_to_fight", true) and combatiente["current_dist"] >= turn_threshold:
					combatientes_listo.append(combatiente)

			if combatientes_listo.is_empty():
				break

			combatientes_listo.sort_custom(func(a, b): return a["current_dist"] > b["current_dist"])

			var winner = combatientes_listo[0]
			winner["current_dist"] -= turn_threshold

			var turn_snapshot: Dictionary = winner.duplicate(true)
			turnArray.append(turn_snapshot)

			if winner["type"] == "player":
				print_rich("Turno %d: [color=green][b]JUGADOR (%s)[/b][/color]" % [turnArray.size(), winner["name"]])
			else:
				print_rich("Turno %d: [color=red][b]ENEMIGO (%s)[/b][/color]" % [turnArray.size(), winner["name"]])
	print("turnArray")
	

func turns():
	if battle_paused:
		return
	while turnArray.size() < 5:
		nextTurns()
		turn()
	
	var turn = turnArray.pop_front()

	if turn["type"] == "enemy" and turn["able_to_fight"]:
		turn["node"].basic_attack(turn["node"].pick_random_character())
		return
	elif turn["type"] == "player": 
		turn["node"]._activate_turn()
		return
	else:
		print_rich("[color=yellow]Aviso:[/color] Cola de turnos vacía.")

func chooseBackgroundScenary(scenary_fight_background):
	if scenary_fight_background == "lol":
		$ColorRect3.self_modulate = Color("61bc58")

func _on_timer_timeout() -> void:
	get_tree().paused = false

func turn():
	var i = 0
	for node in $CanvasLayer/Node2D.get_children():
		if node is Node2D:
			node.enemy_of_origin = turnArray[i]["main_body_node"]
			var sprite_resource = "res://assets/recursos/"+turnArray[i]["name"]+".tres"
			node.TypeCard.animation = turnArray[i]["type"]
			node.CharacterCard.sprite_frames = load(sprite_resource)
			node.CharacterCard.play("Idle")
			i += 1

func enterExitAnimation():
	var tween := create_tween()
	$CanvasLayer/BackBufferCopy/ColorRect.material.set_shader_parameter("progress", 0.7)  
	$CanvasLayer/BackBufferCopy/ColorRect.material.set_shader_parameter("pixel_count", 264.0) 

	tween.tween_property($CanvasLayer/BackBufferCopy/ColorRect.material, "shader_parameter/progress", 0, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property($CanvasLayer/BackBufferCopy/ColorRect.material, "shader_parameter/pixel_count", 16.0, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

func Posible_spawn_positions(Posible_positions) -> Vector3:
	if !Posible_positions.is_empty():
		return Posible_positions.pop_front().global_position
	else:
		return Vector3(0,0,0)

func update_characters_in_fight(character_to_delete : Node3D):
	var target_id: int = character_to_delete.data.get("id", -1)
	for combatiente in combatientes:
		if combatiente["id"] == target_id:
			combatiente["able_to_fight"] = false
			combatiente["speed"] = 0.0
	turnArray = turnArray.filter(func(turn): return turn["node"] != character_to_delete)
	
	var check_enemies = 0
	var check_players = 0
	for combatiente in combatientes:
		if combatiente["type"] == "enemy" and combatiente["able_to_fight"]:
			check_enemies += 1
		if combatiente["type"] == "player" and combatiente["able_to_fight"]:
			check_players += 1
	if check_enemies == 0:
		instanciate_end()
	if check_players == 0:
		Defeat()
	check_enemies = 0
	check_players = 0
	nextTurns()
	turn()

func instanciate_end():
	get_parent().get_parent().music_selector("end_fight")
	var scene = END_FIGHT_SCENE.instantiate()
	for node in enemies_origin_nodes:
		node.queue_free()
	add_child(scene)

func Defeat():
	battle_paused = true
	$AnimationPlayer.play("Defeat")
	get_parent().get_parent().music_selector("end_fight")

#region Enemy selection
const SELECT_ARROW = preload("res://scenes/fightSceneElements/Select_arrow.tscn")
var selected_enemies : Array = []

func selected_enemy(Enemy_node : Array):
	var actual_arrows = get_tree().get_nodes_in_group("SELECTARROW")
	selected_enemies.clear()
	for arrow : AnimatedSprite3D in actual_arrows:
		arrow.remove_from_group("SELECTARROW")
		arrow.material_override.set_shader_parameter("enable_outline", false)
	
	for node : Node3D in Enemy_node:
		#print(node.name +" "+ str(node.get_node("SelectorPosition").position))
		#var arrow = SELECT_ARROW.instantiate()
		selected_enemies.append(node)
		#if node.data:
			#if node.data["type"] == "player":
				#arrow.get_node("OmniLight3D").light_color = Color("a3a200")
			#else:
				#arrow.get_node("OmniLight3D").light_color = Color("c81e4f")
		#node.add_child(arrow)
		#arrow.position = node.get_node("SelectorPosition").position

func select_all_enemies():
	var all_body_parts : Array = get_tree().get_nodes_in_group("EnemyBodyPart")
	for i : Node3D in all_body_parts:
		i.get_node("AnimatedSprite3D").add_to_group("SELECTARROW")
		i.get_node("AnimatedSprite3D").material_override.set_shader_parameter("enable_outline", true)
	#selected_enemy(all_body_parts)
#endregion
