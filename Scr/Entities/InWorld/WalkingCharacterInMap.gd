extends CharacterBody3D
class_name WalkingCharacterInMap

@export var stats : EnemiesInMapData
@export var icon :CompressedTexture2D = load("res://Assets/Art/2DSprites/flecha.png")
@onready var sprite : AnimatedSprite3D = $RotableObjects/AnimatedSprite3D
@onready var original_position = global_position
@onready var zone_node = get_parent().get_parent()
var map_sprite = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if velocity.y >= -2.5:
			velocity += get_gravity() * delta
		
	move_and_slide()

func change_resource(newResource : String):
	stats = load(newResource)
	set_sprite_frames()

func _process(delta: float) -> void:
	if map_sprite:
		map_sprite.position =  Vector2(global_position.x, global_position.z) * 50 

func set_sprite_frames() -> void:
	if stats.character:
		sprite.sprite_frames = load(stats.character.get_path())
		sprite.play("Idle")
	sprite.set_collision_size()

func create_map():

	var parent_node = GameDataManager.MAIN.mini_map.maps

	var sprite = Sprite2D.new()
	sprite.texture = icon
	parent_node.add_child(sprite)
	sprite.z_index = 1
	sprite.position =  Vector2(global_position.x,global_position.z) * 50 
	map_sprite = sprite
