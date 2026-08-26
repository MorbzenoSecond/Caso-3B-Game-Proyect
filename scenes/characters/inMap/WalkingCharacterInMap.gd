extends CharacterBody3D
class_name WalkingCharacterInMap

@export var stats : EnemiesInMapData
@onready var sprite : AnimatedSprite3D = $RotableObjects/AnimatedSprite3D
@onready var original_position = global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func change_resource(newResource : String):
	stats = load(newResource)
	set_sprite_frames()

func set_sprite_frames() -> void:
	if stats.character:
		sprite.sprite_frames = load(stats.character.get_path())
		sprite.play("Idle")
	sprite.set_collision_size()
