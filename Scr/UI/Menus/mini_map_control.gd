extends Control

@onready var maps = $Control/Maps 
@onready var buttons =$Control/ButtonMovementControl
@onready var timer = $Timer


var map_speed = 75

var tween : Tween
var modulate_tween : Tween
var go_out : bool = true
var map_manipulate_mode : bool = false

func _process(delta: float) -> void:
	buttons_process_logic(delta)
	
	if !map_manipulate_mode:
		maps.position = -Vector2(GameDataManager.MAIN.MainCharacter.global_position.x, GameDataManager.MAIN.MainCharacter.global_position.z) * 50 + Vector2(120,120)
	
	if Input.is_action_just_pressed("MapButton"):
		if go_out:
			appear_disapear_animation()
			modulate_animation()
			timer.start(3)
		else:
			appear_disapear_animation()
			modulate_animation(Color(1.0, 1.0, 1.0, 0.204))

func appear_disapear_animation():
	$AudioCentral/ButtonNoise.play()
	if tween:
		if tween.is_running():
			tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	
	if go_out:
		tween.tween_property(self, "map_manipulate_mode", false, 0)
		tween.tween_property(self, "position", Vector2(832.0,2), 0.5)
		go_out = false
	else:
		tween.tween_property(self, "position", Vector2(1152.0,2), 0.5)
		go_out = true

func modulate_animation(color : Color = Color(1.0, 1.0, 1.0, 0.855)):
	if modulate_tween:
		if modulate_tween.is_running():
			modulate_tween.kill()
	
	modulate_tween = create_tween()
	modulate_tween.set_ease(Tween.EASE_OUT)

	modulate_tween.tween_property(self, "modulate", color, 0.5)

func _on_timer_timeout() -> void:
	modulate_animation(Color(1.0, 1.0, 1.0, 0.204))

func _on_button_button_down() -> void:
	appear_disapear_animation()

func _on_mouse_entered() -> void:
	timer.stop()
	modulate_animation()

func _on_mouse_exited() -> void:
	timer.start()

func _on_v_slider_value_changed(value: float) -> void:
	$AudioCentral/SliderNoise.play(0.50)
	for i in maps.get_children():
		if i is Control:
			for e in i.get_children():
				if not e.name.to_int() <= value:
					e.visible = false
				else:
					e.visible = true

func buttons_process_logic(delta):
	if $Control/ButtonMovementControl/UpButton.is_hovered():
		map_manipulate_mode = true
		maps.position += Vector2(0, map_speed) * delta
	if $Control/ButtonMovementControl/DownButton.is_hovered():
		map_manipulate_mode = true
		maps.position += Vector2(0, -map_speed) * delta
	if $Control/ButtonMovementControl/RightButton.is_hovered():
		map_manipulate_mode = true
		maps.position += Vector2(-map_speed, 0) * delta
	if $Control/ButtonMovementControl/LeftButton.is_hovered():
		map_manipulate_mode = true
		maps.position += Vector2(map_speed, 0) * delta

func _on_check_button_pressed() -> void:
	$AudioCentral/ButtonNoise.play()
