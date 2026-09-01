@tool
extends Node3D

@onready var hit_position_1 = $Node3D/HitPosition1
@onready var hit_position_2 = $Node3D/HitPosition2
@onready var hit_position_3 = $Node3D/HitPosition3
@onready var actions_positions = $ActionsPosition
@onready var original_position = global_position
@onready var FIGHT_SCENE_PATH = get_parent().get_parent()

@export var FightResourceStats : FightMovementsResource

const BODY_PART_SCENE = preload("res://scenes/fightSceneElements/body_part.tscn")
const INTERFACE_SCENE = preload("res://scenes/fightSceneElements/player_interface.tscn")

var true_damage : float = 0.0
var true_speed : float = 0.0
var main_body_part
var body_parts : Array
var data : Dictionary

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

		actions_positions.position =  FightResourceStats.actions_positions

		var render_priority_index : int = 0
		var position_index : float = 0.00
		if !FightResourceStats.BodyParts.is_empty():
			for body_part in FightResourceStats.BodyParts:
				var scene : Node3D = BODY_PART_SCENE.instantiate()
				$BodyParts.add_child(scene)
				scene.name = body_part.character.resource_name
				scene.get_node("AnimatedSprite3D").set_collision_size()
				scene.setup(body_part, position_index, render_priority_index)

				if body_part.main_body_part:
					main_body_part = scene

				scene.parent_enemy = self
				body_parts.append(scene)

				render_priority_index -= 1
				position_index -= 0.01
				
				scene.add_to_group("EnemyBodyPart")
				

func level_stats_scalling():
	true_damage = FightResourceStats.base_damage + data["level"]
	true_speed = FightResourceStats.base_speed + data["level"]

func attack_everyone(_damage):
	pass
	#for i in FIGHT_SCENE_PATH.get_node("Characters").get_children():
		#i.get_damage(damage)

func attack(damage, Character_node :Node3D):
	Character_node.get_damage(damage)

func _activate_turn():
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
