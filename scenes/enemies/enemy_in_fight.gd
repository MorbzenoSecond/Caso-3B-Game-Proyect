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
	$AnimatedSprite2D.play("Idle")
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
		if FileAccess.file_exists(SpriteResourceDirection):
			$AnimatedSprite2D.sprite_frames = load(SpriteResourceDirection)
			$AnimatedSprite2D.set_collision_size(original_position.y)
			$AnimatedSprite2D.play("Idle")

		levelLabel.text = "LV" + str(character_data["level"])
		nameLabel.text = character_data["name"]
		liveBar.max_value = true_live
		max_live = true_live
		liveBar.value = true_live
		
		liveDataLabel.text = str(true_live)+"/"+str(true_live)

func level_stats_scalling():
	true_live = FightResourceStats.base_life + data["level"]
	true_damage = FightResourceStats.base_damage + data["level"]
	true_speed = FightResourceStats.base_speed + data["level"]

func attack(damage, Character_node :Node3D):
	Character_node.get_damage(damage)

func attack_everyone(damage):
	for i in FIGHT_SCENE_PATH.get_node("Characters").get_children():

		i.get_damage(damage)

func get_damage(damage):
	true_live -= damage
	liveBar.value = true_live
	liveDataLabel.text = str(true_live) +"/"+str(max_live)
	if true_live <= 0 and  $AnimatedSprite2D.animation != "Death":
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
	return characters.pick_random()
