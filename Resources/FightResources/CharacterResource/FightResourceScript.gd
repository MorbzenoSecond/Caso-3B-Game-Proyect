extends Resource
class_name FightMovementsResource

@export var SpecialActions : Array[FightMovements]

@export var actions_positions : Vector3 = Vector3.ZERO
@export_group("base_stats")
@export var base_speed : float
@export var base_damage : float
@export var base_life : float

@export_group("base_stats")
@export var BodyParts : Array[BodyPart]
