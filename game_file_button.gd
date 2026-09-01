extends Control

var game_file = ""
@onready var button_control = $Button
@onready var time_label = $Button/TimeLabel

func _on_button_pressed() -> void:
	GameDataManager.current_save_file = game_file
	GameDataManager.current_save_file_base_name = $Button/Label.text
	get_parent().get_parent().get_parent().get_parent().start_game()

func _on_button_mouse_entered() -> void:
	tween(20, Vector2(1.05, 1.05))
	


func _on_button_mouse_exited() -> void:
	tween(0, Vector2(1, 1))


var animation_tween : Tween

func tween(side, size):
	if animation_tween:
		if !animation_tween.is_running():
			animation_tween.kill()
	animation_tween = create_tween()
	
	print(button_control.scale)
	animation_tween.tween_property(button_control, "position:x", side, 0.15).set_trans(Tween.TRANS_BOUNCE)
	animation_tween.parallel().tween_property(button_control, "scale", size , 0.12).set_trans(Tween.TRANS_BOUNCE)
