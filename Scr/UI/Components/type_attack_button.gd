extends Control

var movement_resource : FightMovements
@onready var button = $TypeAttackButton

func setup():
	pass

var animation_tween : Tween

func tween(new_size):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	
	animation_tween.parallel().tween_property(button, "scale", new_size , 0.12).set_trans(Tween.TRANS_BOUNCE)
