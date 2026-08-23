class_name EnemiesInMapData
extends Resource

@export var character : SpriteFrames
@export var RUN_MAX_SPEED : float= 0.8
@export var ACCELERATION :float= 1.2

@export var SpecialActions : Array[EnemyAction]
@export var enemy_data : Dictionary =  {
		"Enemies": [
			{
				"name": "MoshPunch",
				"level": 2,
			},
		]
	}
