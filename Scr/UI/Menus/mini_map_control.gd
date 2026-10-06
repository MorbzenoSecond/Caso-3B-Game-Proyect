extends Control

@onready var maps = $Control/Maps 
var tween : Tween
var modulate_tween : Tween
var go_out : bool = true

func _on_v_slider_value_changed(value: float) -> void:
	for i in maps.get_children():
		if i is Control:
			for e in i.get_children():
				if not e.name.to_int() <= value:
					e.visible = false
				else:
					e.visible = true

func appear_disapear_animation():
	if tween:
		if tween.is_running():
			tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	
	if go_out:
		tween.tween_property(self, "position", Vector2(832.0,2), 0.5)
		go_out = false
	else:
		tween.tween_property(self, "position", Vector2(1152.0,2), 0.5)
		go_out = true

func _on_button_button_down() -> void:
	appear_disapear_animation()

func _on_mouse_entered() -> void:
	modulate_animation()

func _on_mouse_exited() -> void:
	modulate_animation(Color(1.0, 1.0, 1.0, 0.204))

func modulate_animation(color : Color = Color(1.0, 1.0, 1.0, 0.855)):
	if modulate_tween:
		if modulate_tween.is_running():
			modulate_tween.kill()
	
	modulate_tween = create_tween()
	modulate_tween.set_ease(Tween.EASE_OUT)

	modulate_tween.tween_property(self, "modulate", color, 0.5)
