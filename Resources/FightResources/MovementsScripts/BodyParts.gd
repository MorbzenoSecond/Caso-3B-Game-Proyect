extends Resource
class_name BodyPart

@export var character : SpriteFrames
@export var main_body_part : bool = false

@export var selector_point_position : Vector3 = Vector3.ZERO

@export_group("local_stats")
@export var local_life : float = 0.0
@export var local_defense : float = 0.0

@export_group("shape_stats")
@export var shape3D : Shape3D
@export var shape_position : Vector3
