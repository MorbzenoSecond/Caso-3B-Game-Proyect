extends AnimatedSprite3D

const AFTERIMAGESCENE = preload("res://scenes/General/AfterImages.tscn")

@export var color : Color = Color(1, 1, 1, 0)
@export var time : float = 0.35
var afterimage_timer := 0.0
var afterimage_interval := 0.1

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	afterimage_timer += delta
	if afterimage_timer >= afterimage_interval:
		afterimage_timer -= afterimage_interval 
		spawn_afterimage()
#
func spawn_afterimage():
	var img = AFTERIMAGESCENE.instantiate()
	GameDataManager.MAIN.Dumpster.add_child(img)
	img.setup(
		sprite_frames.resource_path,
		animation,
		frame,
		global_position,
		global_rotation,
		color,
		time
	)

func set_collision_size():
	if sprite_frames.get_frame_texture("Idle", 0).get_size() == Vector2(128,128):
		position.y += 0.42
	if sprite_frames.get_frame_texture("Idle", 0).get_size() == Vector2(64,64):
		position.y += 0.096
