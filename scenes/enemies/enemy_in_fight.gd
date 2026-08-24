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
var main_body_part
var body_parts : Array

const BODY_PART_SCENE = preload("res://scenes/fightSceneElements/body_part.tscn")

@export var shoot_type : PackedScene 

@onready var FIGHT_SCENE_PATH = get_parent().get_parent()

var data : Dictionary

var max_live : float = 0.0

var true_damage : float = 0.0
var true_live : float = 0.0
var true_speed : float = 0.0

const INTERFACE_SCENE = preload("res://scenes/fightSceneElements/player_interface.tscn")

@export var FightResourceStats : FightMovementsResource

func basic_attack(target_node: Node3D):
	var i = FightResourceStats.SpecialActions.pick_random()
	i.executed(self, target_node)

func _ready() -> void:
	await get_tree().process_frame
	original_position = global_position

func setup(character_data : Dictionary):
	if character_data:
		data = character_data
		match character_data["type"] as String:
			"player":
				hit_position_1.position.x = 0.2
				hit_position_2.position.x = 0.7
				hit_position_3.position.x = 0.15
			"enemy":
				hit_position_1.position.x = -0.2
				hit_position_2.position.x = -0.75
				hit_position_3.position.x = -0.15

		var ResourceDirection = "res://Resources/FightResources/CharacterResource/"+data["name"]+"FightResource.tres"
		if FileAccess.file_exists(ResourceDirection):
			FightResourceStats = load(ResourceDirection)
			level_stats_scalling()
			#await FightResourceStats.property_list_changed

		var SpriteResourceDirection = "res://assets/recursos/"+character_data["name"]+".tres"

		levelLabel.text = "LV" + str(character_data["level"])
		nameLabel.text = character_data["name"]
		liveBar.max_value = true_live
		max_live = true_live
		liveBar.value = true_live

		liveDataLabel.text = str(true_live)+"/"+str(true_live)

		var render_priority_index : int = 0
		var position_index : float = 0.00
		if !FightResourceStats.BodyParts.is_empty():
			for body_part in FightResourceStats.BodyParts:
				var scene : Node3D = BODY_PART_SCENE.instantiate()
				$BodyParts.add_child(scene)
				scene.name = body_part.character.resource_name
				scene.get_node("AnimatedSprite3D").sprite_frames = body_part.character
				scene.get_node("AnimatedSprite3D").render_priority = render_priority_index 
				scene.get_node("AnimatedSprite3D").set_collision_size(original_position.y)
				scene.get_node("Area3D/CollisionShape3D").shape = body_part.shape3D
				scene.get_node("Area3D/CollisionShape3D").position = body_part.shape_position + Vector3(0, position_index, position_index)
				scene.get_node("SelectorPosition").position = body_part.selector_point_position
				scene.local_life = body_part.local_life
				
				if body_part.main_body_part:
					main_body_part = scene
				
				scene.parent_enemy = self
				body_parts.append(scene)

				render_priority_index -= 1
				position_index -= 0.01

				#scene.get_node("Area3D").input_event.connect(_on_area_3d_input_event)

func level_stats_scalling():
	true_live = FightResourceStats.base_life + data["level"]
	true_damage = FightResourceStats.base_damage + data["level"]
	true_speed = FightResourceStats.base_speed + data["level"]

func attack_everyone(damage):
	for i in FIGHT_SCENE_PATH.get_node("Characters").get_children():
		i.get_damage(damage)

func attack(damage, Character_node :Node3D):
	Character_node.get_damage(damage)

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
	tween.tween_callback(attack_everyone.bind(FightResourceStats.base_damage))
	
	# Pausa breve en el suelo tras el choque para simular masa
	tween.tween_interval(0.15) 

	# --- 5. REGRESO ---
	tween.tween_property(self, "global_position", original_pos, 0.8)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(FIGHT_SCENE_PATH.turns)

func pick_random_character() -> Node3D:
	var characters : Array = []
	for combatiente in FIGHT_SCENE_PATH.combatientes:
		if combatiente["type"] == "player" and combatiente["able_to_fight"]:
			characters.append(combatiente["node"])
	return characters.pick_random().body_parts.pick_random()
