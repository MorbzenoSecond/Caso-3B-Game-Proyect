@tool
extends Node3D

@onready var movements_container = $CanvasLayer/Control/BoxContainer/VBoxContainer

@export var battle_paused : bool = false

var charactersInBattleArray : Dictionary = {}
var turnDictionary : Dictionary = {}
var enemies_origin_nodes : Array = []
var combatientes: Array = []
var turnArray : Array = []
var selected_enemies : Array = []

const ENEMY_SCENE = preload("res://scenes/enemies/enemy_in_fight.tscn")
const END_FIGHT_SCENE = preload("res://scenes/fightSceneElements/fight_end_scene.tscn")
const TYPE_MOVEMENT_SCENE = preload("res://type_attack_button.tscn")
const SELECT_ARROW = preload("res://scenes/fightSceneElements/Select_arrow.tscn")

func setup():
	$CanvasLayer.visible = true
	await set_keys()
	await turns()
	enterExitAnimation()
	$AnimationPlayer.play("ingrese")

func clean():
	battle_paused = false
	for e in $Enemies.get_children():
		e.queue_free()
	for e in $Characters.get_children():
		e.queue_free()
	turnArray.clear()
	charactersInBattleArray.clear()
	turnDictionary.clear()
	enemies_origin_nodes.clear()
	combatientes.clear()

func finish_fight():
	$AnimationPlayer.play_backwards("ingrese")
	await enterExitAnimation()
	$CanvasLayer.visible = false
	await clean()
	GameDataManager.MAIN.finish_fight()

func set_keys():
	if !charactersInBattleArray.is_empty():
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
					character_to_instanciate.name = player["name"]
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
					character_to_instanciate.name = enemy["name"]

func nextTurns():
	if !charactersInBattleArray.is_empty():
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
	if !charactersInBattleArray.is_empty():
		if battle_paused:
			return
		while turnArray.size() < 5:
			nextTurns()
			turn()
		
		var next_turn = turnArray.pop_front()
		
		for movement in movements_container.get_children():
			movement.queue_free()

		if next_turn["type"] == "enemy" and next_turn["able_to_fight"]:
			next_turn["node"].opponent_attack_logic()
			return
		elif next_turn["type"] == "player":
			next_turn["node"]._activate_turn()
			return
		else:
			print_rich("[color=yellow]Aviso:[/color] Cola de turnos vacía.")

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

	await tween.finished

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

func chooseBackgroundScenary(scenary_fight_background):
	if scenary_fight_background == "lol":
		$ColorRect3.self_modulate = Color("61bc58")

func ItemEffect(item_name, character):
	match item_name:
		"healer":
			character.use_item(2)
			pass 
		"item_two":
			character.use_item(3)
	pass

#region Button instanciate
func instanciate_return_button(node):
	var return_button = TYPE_MOVEMENT_SCENE.instantiate()
	movements_container.add_child(return_button)
	return_button.button.get_node("Label").text = "Regresar"
	return_button.button.button_down.connect(_on_return_button_pressed.bind(node))

func instanciate_execute_button(node):
	var return_button = TYPE_MOVEMENT_SCENE.instantiate()
	movements_container.add_child(return_button)
	return_button.button.get_node("Label").text = "Ejecutar"
	return_button.button.button_down.connect(_on_execute_button_pressed.bind(node))

func prepare_scape_options(node):
	instanciate_return_button(node)
	var scape_button = TYPE_MOVEMENT_SCENE.instantiate()
	movements_container.add_child(scape_button)
	scape_button.button.get_node("Label").text = "Escapar"
	scape_button.button.button_down.connect(_on_scape_button_pressed)

func prepare_attack_options(node):
	instanciate_return_button(node)
	for attack : Resource in node.FightResourceStats.SpecialActions:
		var button = TYPE_MOVEMENT_SCENE.instantiate()
		movements_container.add_child(button)
		button.movement_resource = attack
		button.button.button_down.connect(_on_attack_button_pressed.bind(button, node))
		button.button.size = Vector2(224, 65)

		if attack.resource_name:
			button.button.get_node("Label").text = attack.resource_name
	instanciate_execute_button(node)

func prepare_item_options(node):
	instanciate_return_button(node)
	for item : Dictionary in GameDataManager.data["Items"]:
		var button = TYPE_MOVEMENT_SCENE.instantiate()
		movements_container.add_child(button)
		button.button.button_down.connect(_on_item_button_pressed.bind(item.item_name, node))
		button.button.size = Vector2(224, 65)

		if item.item_name:
			button.button.get_node("Label").text = item.item_name

func _on_attack_button_pressed(button_node, node):
	await unselect_objetive()
	if button_node.movement_resource.all_targets:
		select_all_oponnents()
	else:
		select_random_oponents()
	for movement_container in movements_container.get_children():
		if movement_container.button.scale == Vector2(1,1):
			continue
		movement_container.tween(Vector2(1, 1))
	if !selected_enemies.is_empty():
		node.selected_attack = button_node.movement_resource
	button_node.tween(Vector2(1.2, 1.2))

func _on_item_button_pressed(item, node):
	if !selected_enemies.is_empty():
		for movement in movements_container.get_children():
			movement.button.disabled = true
		for character in selected_enemies:
			ItemEffect(item, character)

func _on_execute_button_pressed(node):
	if !selected_enemies.is_empty():
		for movement in movements_container.get_children():
			movement.button.disabled = true
		node.basic_attack(selected_enemies)
		unselect_objetive()

func _on_scape_button_pressed():
	finish_fight()

func _on_return_button_pressed(node):
	unselect_objetive()
	node._activate_turn() 
	for movement in movements_container.get_children():
		movement.queue_free()
#endregion

#region Enemy selection
func selected_enemy(Enemy_node : Array):
	var actual_arrows = get_tree().get_nodes_in_group("SELECTARROW")
	selected_enemies.clear()
	for arrow : AnimatedSprite3D in actual_arrows:
		arrow.remove_from_group("SELECTARROW")
		arrow.material_override.set_shader_parameter("enable_outline", false)
	
	for node : Node3D in Enemy_node:
		selected_enemies.append(node)

func unselect_objetive():
	var actual_arrows = get_tree().get_nodes_in_group("SELECTARROW")
	for arrow : AnimatedSprite3D in actual_arrows:
		arrow.remove_from_group("SELECTARROW")
		arrow.material_override.set_shader_parameter("enable_outline", false)

	selected_enemies.clear()

func select_random_oponents():
	var random_part : = get_tree().get_first_node_in_group("EnemyBodyPart")
	if !random_part.get_node("AnimatedSprite3D").is_in_group("SELECTARROW"):
		selected_enemies.append(random_part)
		random_part.get_node("AnimatedSprite3D").add_to_group("SELECTARROW")
		random_part.get_node("AnimatedSprite3D").material_override.set_shader_parameter("enable_outline", true)

func select_all_oponnents():
	var all_body_parts : Array = get_tree().get_nodes_in_group("EnemyBodyPart")
	for i : Node3D in all_body_parts:
		if i.parent_enemy.data["type"] == "enemy":
			selected_enemies.append(i)
			i.get_node("AnimatedSprite3D").add_to_group("SELECTARROW")
			i.get_node("AnimatedSprite3D").material_override.set_shader_parameter("enable_outline", true)
			i.get_node("AnimatedSprite3D").material_override.set_shader_parameter("outline_color", Color("ffff00"))
#endregion
