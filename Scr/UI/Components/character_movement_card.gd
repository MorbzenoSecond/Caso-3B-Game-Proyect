extends Control

@onready var allies = $MarginContainer/Characters/Allies
@onready var enemies =  $MarginContainer/Characters/Enemies
@onready var attack_name_label = $Label
@onready var back_ground = $MarginContainer/BackGround

var appear_tween : Tween

func setup(characters: Array = [], movement_name : String = "<no name attack>", origin_character_side : String = "player" ):
	clear()
	
	var character_to_hit : int = 0
	var enemy_to_hit : int = 0
	
	for character in characters:
		var new_animated_sprite_2d = AnimatedSprite2D.new()
		
		if character.parent_enemy.data["type"] == "player":
			allies.add_child(new_animated_sprite_2d)
			new_animated_sprite_2d.position.x += character_to_hit
			character_to_hit -= 6
		else:
			enemies.add_child(new_animated_sprite_2d)
			new_animated_sprite_2d.position.x += enemy_to_hit
			enemy_to_hit += 6

		new_animated_sprite_2d.sprite_frames = load(character.animated_sprite_3D.sprite_frames.resource_path)
		new_animated_sprite_2d.play("Idle")

	back_ground.play(origin_character_side)
	if origin_character_side == "enemy":
		position = Vector2(400, 225)
		appear_animation(320, 310)
	else:
		position = Vector2(-10, 225)
		appear_animation(60, 70)

	attack_name_label.text = movement_name

func clear():
	for i in allies.get_children():
		i.queue_free()
	for i in enemies.get_children():
		i.queue_free()

func appear_animation(new_position, position_rash):
	if appear_tween:
		if appear_tween.is_running():
			appear_tween.kill()
	
	appear_tween = create_tween()
	appear_tween.set_ease(Tween.EASE_OUT)

	appear_tween.tween_property(self, "modulate", Color("ffffff00"), 0)
	appear_tween.tween_property(self, "modulate", Color("ffffff"), 0.25)
	appear_tween.parallel().tween_property(self, "position:x", new_position, 0.2)
	appear_tween.tween_property(self, "position:x", position_rash, 1.5).set_ease(Tween.EASE_OUT_IN)
	appear_tween.parallel().tween_interval(1.2)
	appear_tween.tween_property(self, "modulate", Color("ffffff00"), 0.25)
	
