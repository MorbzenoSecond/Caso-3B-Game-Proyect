extends Control

var movement_resource : FightMovements 

@onready var button = $TypeAttackButton
@onready var sprite = $TypeAttackButton/targets
@onready var icon = $TypeAttackButton/Icon
@onready var effects_animated_sprite_2D = $TypeAttackButton/effect

@onready var name_label = $TypeAttackButton/NameLabel
@onready var number_label = $TypeAttackButton/NumberLabel

var animation_tween : Tween
var appear_tween : Tween

func animation(new_size):
	tween(new_size)

func tween(new_size, self_size = 180, control_size = 84):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	animation_tween.parallel().tween_property($TypeAttackButton/Control, "size:y", control_size, 0.12).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(self, "custom_minimum_size:y", self_size , 0.12).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(button, "scale", new_size , 0.12).set_trans(Tween.TRANS_BOUNCE)

func appear_animation():
	if appear_tween:
		if appear_tween.is_running():
			appear_tween.kill()
	
	appear_tween = create_tween()
	appear_tween.set_ease(Tween.EASE_OUT)

	appear_tween.parallel().tween_property(button, "position:x", 0, 0.22)
	appear_tween.parallel().tween_property(self, "modulate", Color("ffffff"), 0.34)
