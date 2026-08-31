class_name EnemiesInMapData
extends Resource

@export var character : SpriteFrames
@export var RUN_MAX_SPEED : float= 0.8
@export var ACCELERATION :float= 1.2

@export var SpecialActions : Array[EnemyAction]
@export var SmartEnemy : bool = false
@export var enemy_data : Dictionary =  {
		"Enemies": [
			{
				"name": "MoshPunch",
				"level": 2,
			},
		]
	}

@export_group("body_collision")
@export var body_collision_type = Shape3D
@export var body_collision_position : Vector3 = Vector3.ZERO

@export_group("areas_collision")
@export var character_area_collision_type = Shape3D
@export var character_area_collision_position : Vector3 = Vector3.ZERO
