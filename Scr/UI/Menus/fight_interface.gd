extends Control

@onready var fight_scene = get_parent().get_parent()
@onready var origin_character = $"../../"

var appear_tween : Tween

func clean():
	var box_items = $MovementTypeControl/ScrollContainer/VBoxContainer.get_children()
	for i : TextureButton in $MenuControl.get_children():
		if !i.is_hovered():
			var icon_path = "res://Assets/Art/2DSprites/Icons/"+ i.name+".png"
			i.texture_normal = load(icon_path)
	if !box_items.is_empty():
		for i in box_items:
			i.queue_free()

var animation_tween : Tween

func scale_tween(button : TextureButton):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	var icon_path = "res://Assets/Art/2DSprites/Icons/"+ button.name +"Foccused.png"
	animation_tween = create_tween()

	if FileAccess.file_exists(icon_path):
		animation_tween.tween_property(button, "texture_normal", load(icon_path) , 0)
	animation_tween.tween_property(button, "scale", Vector2(3.6,3.6) , 0.05).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.tween_interval(0.05)
	animation_tween.tween_property(button, "scale", Vector2(4,4) , 0.1).set_trans(Tween.TRANS_BOUNCE)

func appear_animation():
	if appear_tween:
		if appear_tween.is_running():
			appear_tween.kill()
	
	appear_tween = create_tween()
	appear_tween.set_ease(Tween.EASE_OUT)

	appear_tween.tween_property(self, "modulate", Color("ffffff00"), 0)
	appear_tween.tween_property(self, "modulate", Color("ffffff"), 0.25)

func disappear_animation():
	if appear_tween:
		if appear_tween.is_running():
			appear_tween.kill()
	
	appear_tween = create_tween()
	appear_tween.set_ease(Tween.EASE_OUT)

	appear_tween.tween_property(self, "modulate", Color("ffffff"), 0)
	appear_tween.tween_property(self, "modulate", Color("ffffff00"), 0.25)

func _on_movement_button_button_down() -> void:
	await clean()
	scale_tween($MenuControl/MovementButton)
	if fight_scene:
		fight_scene.prepare_attack_options(origin_character)

func _on_objects_button_button_down() -> void:
	await clean()
	scale_tween($MenuControl/ObjectsButton)
	if fight_scene:
		fight_scene.prepare_item_options(origin_character)

func _on_special_movement_button_button_down() -> void:
	await clean()
	scale_tween($MenuControl/SpecialMovementButton)
	if fight_scene:
		fight_scene.prepare_attack_options(origin_character)

func _on_scape_button_button_down() -> void:
	await clean()
	scale_tween($MenuControl/ScapeButton)
	if fight_scene:
		fight_scene.prepare_scape_options(origin_character)
