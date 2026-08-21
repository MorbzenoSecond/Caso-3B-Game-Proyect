@tool
extends Node3D

@onready var nameLabel = $Sprite3D/Name
@onready var levelLabel = $Sprite3D/Level
@onready var liveBar = $Sprite3D/SubViewport/Control/ProgressBar
@onready var liveDataLabel = $Sprite3D/livedata
@onready var hit_position_1 = $Node3D/HitPosition1
@onready var hit_position_2 = $Node3D/HitPosition2
@onready var hit_position_3 = $Node3D/HitPosition3
@onready var original_position = global_position
@export var shoot_type : PackedScene 

@onready var FIGHT_SCENE_PATH = get_parent().get_parent()

var myself : Array = [self]
var data : Dictionary
var live : float = 0.0
var max_live : float = 0.0
var damage : float = 1.0

const INTERFACE_SCENE = preload("res://scenes/fightSceneElements/player_interface.tscn")
#enum EnemyType {BOO, GOOMBA} 
#@export var Enemy_type: EnemyType = EnemyType.BOO: 
	#set(value): 
		#Enemy_type = value  
		#match Enemy_type:
			#EnemyType.BOO:
				#$AnimatedSprite2D.sprite_frames = load("res://assets/recursos/Boo.tres")
				#$AnimatedSprite2D.play("Idle")
			#EnemyType.GOOMBA:
				#$AnimatedSprite2D.sprite_frames = load("res://assets/recursos/Goomba.tres")
				#$AnimatedSprite2D.play("Idle")

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")
	await get_tree().process_frame
	original_position = global_position

func setup(character_data : Dictionary):
	if character_data:
		match character_data["type"] as String:
			"player":
				hit_position_1.position.x = 0.2
				hit_position_2.position.x = 0.7
				hit_position_3.position.x = 0.15
			"enemy":
				hit_position_1.position.x = -0.2
				hit_position_2.position.x = -0.75
				hit_position_3.position.x = -0.15

		data = character_data
		if FileAccess.file_exists("res://assets/recursos/"+character_data["name"]+".tres"):
			$AnimatedSprite2D.sprite_frames = load("res://assets/recursos/"+character_data["name"]+".tres")
		$AnimatedSprite2D.play("Idle")
		
		levelLabel.text = "LV" + str(character_data["level"])
		nameLabel.text = character_data["name"]
		
		liveBar.max_value = character_data["life"]
		live = character_data["life"]
		max_live = character_data["life"]
		liveBar.value = character_data["life"]
		damage = character_data["damage"]
		
		await get_tree().process_frame
		
		if $AnimatedSprite2D.sprite_frames.get_frame_texture("Idle", 0).get_size() == Vector2(128,128):
			position.y += 0.421
			original_position.y += 0.421
			print($AnimatedSprite2D.sprite_frames.get_frame_texture("Idle", 0).get_size())
		
		liveDataLabel.text = str(character_data["life"])+"/"+str(character_data["life"])

func attack(damage, Character_node :Node3D):
	Character_node.get_damage(damage)

func attack_everyone(damage):
	for i in FIGHT_SCENE_PATH.get_node("Characters").get_children():
		i.get_damage(damage)

func get_damage(damage):
	
	live -= damage
	liveBar.value = live
	liveDataLabel.text = str(live) +"/"+str(max_live)
	if live <= 0 and  $AnimatedSprite2D.animation != "Death":
		$AnimatedSprite2D.animation = "Death"
		FIGHT_SCENE_PATH.update_characters_in_fight(self)
		#var resource = DialogueManager.create_resource_from_text("~ start \n " + data["name"] + ": hola,soy un "+ data["name"] +"!")
		#DialogueManager.show_example_dialogue_balloon(resource, "start")
		#FIGHT_SCENE_PATH.battle_paused = true
		#await DialogueManager.dialogue_ended
		#FIGHT_SCENE_PATH.battle_paused = false
		#FIGHT_SCENE_PATH.turns()

		return
	if $AnimatedSprite2D.animation == "Idle":
		$AnimatedSprite2D.animation = "Punched"

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Punched":
		$AnimatedSprite2D.play("Idle")

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		get_parent().get_parent().selected_enemy(myself)

func _activate_turn():
	var scene = INTERFACE_SCENE.instantiate()
	$SelectorPosition.add_child(scene)

func get_marker_position(Type : String) -> Vector3:
	match Type as String:
		"hit_position_1":
			return hit_position_1.global_position
		"hit_position_2":
			return hit_position_2.global_position
		"hit_position_3":
			return hit_position_2.global_position
	return Vector3.ZERO

func basic_attack(target_node: Node3D):
	match data["name"] as String:
		"MoshPunch":
			front_direction(target_node)
			#$AnimatedSprite2D.set_process(true)
		"AggroShell":
			shoot_attack(target_node)
		"Player":
			front_direction(target_node)
		"RavenousCrab":
			heavy_jump_attack(target_node)

func front_direction(target_node: Node3D):
	var tween := create_tween()
	tween.tween_property(self, "global_position:x", target_node.get_marker_position("hit_position_1").x, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "global_position:z", target_node.get_marker_position("hit_position_1").z, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_callback(attack.bind(damage, target_node))


	tween.tween_property(self, "global_position", original_position, 1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(FIGHT_SCENE_PATH.turns)

func shoot_attack(target_node: Node3D):
	var tween := create_tween()
	tween.tween_property(self, "global_position:x", target_node.get_marker_position("hit_position_3").x, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "global_position:z", target_node.get_marker_position("hit_position_3").z, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_callback(attack.bind(damage, target_node))
	tween.tween_callback(shoot.bind(global_position.direction_to(target_node.global_position)))

	tween.tween_property(self, "global_position", original_position, 1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(FIGHT_SCENE_PATH.turns)

func heavy_jump_attack(target_node: Node3D) -> void:
	var target_pos: Vector3 = get_marker_position("hit_position_1")
	var original_pos: Vector3 = global_position
	var jump_height: float = 2.0 # Altura del salto
	var jump_time: float = 1.2    # Tiempo total en el aire (mitad subir, mitad caer)
	var half_jump: float = jump_time / 2.0

	var tween := create_tween()

	# --- 1. MOVIMIENTO HORIZONTAL (X y Z) ---
	# Avanza linealmente hacia el objetivo durante todo el salto
	tween.tween_property(self, "global_position:x", target_pos.x, jump_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(self, "global_position:z", target_pos.z, jump_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	# --- 2. SALTO (Eje Y - Subida) ---
	# Sube perdiendo velocidad en la cima
	tween.parallel().tween_property(self, "global_position:y", original_pos.y + jump_height, half_jump)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	# --- 3. CAÍDA Y IMPACTO (Eje Y - Caída Pesada) ---
	# Cae acelerando fuertemente (EASE_IN) para dar peso
	tween.chain().tween_property(self, "global_position:y", target_pos.y + 0.421, half_jump)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	# --- 4. IMPACTO Y ATAQUE ---
	# Daño al tocar suelo
	tween.tween_callback(FIGHT_SCENE_PATH.get_parent().get_parent().camera.add_trauma.bind(0.8))
	tween.tween_callback(attack_everyone.bind(damage))
	
	# Pausa breve en el suelo tras el choque para simular masa
	tween.tween_interval(0.15) 

	# --- 5. REGRESO ---
	tween.tween_property(self, "global_position", original_pos, 0.8)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(FIGHT_SCENE_PATH.turns)

func shoot(direction):
	var scene = shoot_type.instantiate()
	get_parent().add_child(scene)
	
	scene.global_position = $Marker3D.global_position
	
	scene.direction = direction
	scene.node = self
	var flare_tex = $Marker3D/Sprite3D.material_override.get_shader_parameter("flare_texture")

	if flare_tex and flare_tex is GradientTexture2D:
		var grad: Gradient = flare_tex.gradient
		
		if grad.get_point_count() > 0:
			tween()

func tween():
	$AudioStreamPlayer3D2.play()
	var sprite = $Marker3D/Sprite3D
	if sprite.material_override:
		sprite.material_override = sprite.material_override.duplicate()
	var flare_tex = sprite.material_override.get_shader_parameter("flare_texture")

	if flare_tex and flare_tex is GradientTexture2D:
		var grad: Gradient = flare_tex.gradient
		
		if grad.get_point_count() > 1:
			var target_color1 = Color(0.85, 0.38, 0.78)
			var target_color2 = Color(0.99, 0.51, 0.63) 
			
			var start_color1 = Color(0.85, 0.38, 0.78)
			var start_color2 = Color(0.99, 0.51, 0.63)
			var start_offset = 0.01
			
			sprite.material_override.set_shader_parameter("primary_color", start_color1)
			sprite.material_override.set_shader_parameter("secondary_color", start_color2)
			grad.set_offset(1, start_offset)
			var initial_offset = grad.get_offset(1)
			
			var target_offset = 0.99
			var duration = 0.5
			
			var tw = create_tween()

			tw.tween_method(
				func(val: float): grad.set_offset(1, val),
				initial_offset,
				target_offset,
				duration
			).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
			target_color1 = Color(0, 0, 0) 
			target_color2 = Color(0, 0, 0) 
			
			tw.parallel().tween_property(sprite.material_override, "shader_parameter/primary_color", target_color1, duration)
			tw.parallel().tween_property(sprite.material_override, "shader_parameter/secondary_color", target_color2, duration)

func pick_random_character() -> Node3D:
	var characters : Array = []
	for combatiente in FIGHT_SCENE_PATH.combatientes:
		if combatiente["type"] == "player" and combatiente["able_to_fight"]:
			characters.append(combatiente["node"])
	return characters.pick_random()
