extends Node3D

func setup(
	Sprite_Resource : String, 
	Sprite_Animation : StringName = "",
	Sprite_Frame : int = 0,
	Sprite_Position  : Vector3 = Vector3.ZERO,
	Sprite_Rotation : Vector3 = Vector3.ZERO,
	Sprite_moduation : Color = Color(1,1,1,0),
	Sprite_Duration : float = 0.5,
	):
	
	$AnimatedSprite3D.sprite_frames = load(str(Sprite_Resource))
	#await $AnimatedSprite3D.sprite_frames_changed
	$AnimatedSprite3D.animation = Sprite_Animation
	$AnimatedSprite3D.frame = Sprite_Frame
	global_position = Sprite_Position
	$AnimatedSprite3D.rotation = Sprite_Rotation
	
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite3D, "modulate", Sprite_moduation, Sprite_Duration)
	tween.tween_callback(Callable(self, "queue_free"))
