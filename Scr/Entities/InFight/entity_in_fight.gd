@tool
extends Node3D

@onready var hit_position_1 = $Node3D/HitPosition1
@onready var hit_position_2 = $Node3D/HitPosition2
@onready var hit_position_3 = $Node3D/HitPosition3
@onready var actions_positions = $ActionsPosition
@onready var original_position = global_position
@onready var FIGHT_SCENE_PATH = get_parent().get_parent()

@export var FightResourceStats : FightMovementsResource

const BODY_PART_SCENE = preload("res://Scr/Combat/body_part.tscn")
const INTERFACE_SCENE = preload("res://Scr/Combat/player_interface.tscn")

var true_damage : float = 0.0
var true_speed : float = 0.0
var main_body_part
var body_parts : Array
var data : Dictionary
var selected_attack : Resource
var true_energy_capacity : float
var true_energy_recuperation : float
var actual_energy_capacity : float

func _ready() -> void:
	await get_tree().process_frame
	original_position = global_position

func basic_attack(target_node: Array):
	actual_energy_capacity -= selected_attack.energy_consumtion
	var i
	if selected_attack:
		i = selected_attack
		i.executed(self, target_node)
		return

func activate(status):
	main_body_part.animated_sprite_3D.set_process(status)

func provoque():
	var turns = 3
	var provoque_status : = {"origin_entity": self, "BodyPart" : main_body_part, "remaining_turns": turns, "already_checked" : false}
	for entity in FIGHT_SCENE_PATH.focussed_entities:
		if entity["origin_entity"] == provoque_status["origin_entity"]:
			FIGHT_SCENE_PATH.focussed_entities.erase(entity)
	FIGHT_SCENE_PATH.focussed_entities.append(provoque_status)

func opponent_attack_logic():
	await main_body_part.liveBarNode.update_progress_bar(true_energy_capacity, true_energy_recuperation,actual_energy_capacity)
	selected_attack = FightResourceStats.SpecialActions.pick_random()
	var posible_characters : Array = []
	var selected_characters : Array = []
	for character in FIGHT_SCENE_PATH.combatientes:
		if character["type"] == "player" and character.able_to_fight:
			posible_characters.append(character["node"].get_node("BodyParts").get_child(0))

	if selected_attack.all_targets:
		for posible_character in posible_characters:
			selected_characters.append(posible_character)
	elif selected_attack.can_only_target_himself:
		pass
	else:
		if FIGHT_SCENE_PATH.focussed_entities.is_empty():
			posible_characters.clear()
			selected_characters.append(posible_characters.pick_random())
		else:
			for entity in FIGHT_SCENE_PATH.focussed_entities:
				if entity["BodyPart"].parent_enemy.data["type"] == "player":
					selected_characters.append(entity["BodyPart"])
					break
			#selected_characters.append(posible_characters.pick_random())
	basic_attack(selected_characters)
	var active_characters : Array = []
	for selected_character in selected_characters:
		active_characters.append(selected_character)
	active_characters.append(main_body_part)
	main_body_part.liveBarNode.show_energy_usage(actual_energy_capacity)
	actual_energy_capacity -= selected_attack.energy_consumtion
	main_body_part.liveBarNode.progress_bar_alterate(actual_energy_capacity, main_body_part.liveBarNode.energy_texture_process_bar)
	FIGHT_SCENE_PATH.movement_card.setup(active_characters, selected_attack.resource_name, data["type"] )

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

		var ResourceDirection = "res://Resources/FightResources/CharacterResources/"+data["name"]+"FightResource.tres"
		if FileAccess.file_exists(ResourceDirection):
			FightResourceStats = load(ResourceDirection)
			level_stats_scalling()

		actions_positions.position =  FightResourceStats.actions_positions

		actual_energy_capacity = true_energy_capacity / 4

		var render_priority_index : int = 0
		var position_index : float = 0.00
		if !FightResourceStats.BodyParts.is_empty():
			for body_part in FightResourceStats.BodyParts:
				var scene : Node3D = BODY_PART_SCENE.instantiate()
				$BodyParts.add_child(scene)
				scene.name = body_part.character.resource_name
				scene.get_node("AnimatedSprite3D").set_collision_size()
				

				if body_part.main_body_part:
					main_body_part = scene

				scene.parent_enemy = self
				body_parts.append(scene)

				render_priority_index -= 1
				position_index -= 0.01
				scene.setup(body_part, position_index, render_priority_index)
				
				scene.add_to_group("EnemyBodyPart")

func level_stats_scalling():
	true_energy_capacity =  FightResourceStats.base_energy + data["level"]
	true_energy_recuperation = FightResourceStats.base_natural_recuperation + data["level"]
	true_damage = FightResourceStats.base_damage + data["level"]
	true_speed = FightResourceStats.base_speed + data["level"]

func attack(damage, Character_node : Node3D):

	Character_node.get_damage(selected_attack.damage_multiplicator, damage)

func _activate_turn():
	main_body_part.liveBarNode.update_progress_bar(true_energy_capacity, true_energy_recuperation,actual_energy_capacity)
	_instanciate_interface()

func _instanciate_interface():
	var scene = INTERFACE_SCENE.instantiate()
	actions_positions.add_child(scene)

func get_marker_position(Type : String) -> Vector3:
	match Type as String:
		"hit_position_1":
			return hit_position_1.global_position
		"hit_position_2":
			return hit_position_2.global_position
		"hit_position_3":
			return hit_position_2.global_position
	return Vector3.ZERO

func pick_random_character() -> Node3D:
	var characters : Array = []
	for combatiente in FIGHT_SCENE_PATH.combatientes:
		if combatiente["type"] == "player" and combatiente["able_to_fight"]:
			characters.append(combatiente["node"])
	return characters.pick_random().body_parts.pick_random()
# esto es temporal
func character_down():
	for body_part : Node3D in $BodyParts.get_children():
		body_part.animated_sprite_3D.visible = false
	FIGHT_SCENE_PATH.update_characters_in_fight(self)
	if !FIGHT_SCENE_PATH.focussed_entities.is_empty():
		for entity : Dictionary in FIGHT_SCENE_PATH.focussed_entities: 
			if entity["origin_entity"] == self:
				FIGHT_SCENE_PATH.focussed_entities.erase(entity)
