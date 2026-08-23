class_name ShootAction
extends EnemyAction



@export var ShootType : PackedScene 
@export var ShootSpeed: float = 2.0
@export var VisualEffect : Array[PackedScene]

func execute(enemy):
	var scene = ShootType.instantiate()
	GameDataManager.MAIN.Dumpster.add_child(scene)
	
	for node in VisualEffect:
		var effect = node.instantiate()
		scene.get_node("VisualEffect").add_child(effect)
	
	scene.global_position = enemy.shoot_shader.global_position
	
	scene.direction = enemy.direction
	scene.enemy_data = enemy.stats.enemy_data
	scene.node = enemy
	var flare_tex = enemy.shoot_shader.material_override.get_shader_parameter("flare_texture")
#
	if flare_tex and flare_tex is GradientTexture2D:
		var grad: Gradient = flare_tex.gradient
		
		if grad.get_point_count() > 0:
			tween(enemy)

func tween(enemy):
	#$AudioStreamPlayer3D2.play()
	var sprite = enemy.shoot_shader
	if sprite.material_override:
		sprite.material_override = sprite.material_override.duplicate()
	var flare_tex = sprite.material_override.get_shader_parameter("flare_texture")
#
	if flare_tex and flare_tex is GradientTexture2D:
		var grad: Gradient = flare_tex.gradient
		
		if grad.get_point_count() > 1:
			var target_color1 = Color(0.85, 0.38, 0.78)
			var target_color2 = Color(0.99, 0.51, 0.63)
			
			var start_color1 = Color(0.85, 0.38, 0.78)
			var start_color2 = Color(0.99, 0.51, 0.63)
			var start_offset = 0.01
			
			sprite.material_override.set_shader_parameter("primary_color", start_color1)
			sprite.material_override.set_shader_parameter("secondary_color", start_color2)
			grad.set_offset(1, start_offset)
			var initial_offset = grad.get_offset(1)
			
			var target_offset = 0.99
			var duration = 0.5

			var tw : Tween = enemy.get_tree().create_tween()

			tw.tween_method(
				func(val: float): grad.set_offset(1, val),
				initial_offset,
				target_offset,
				duration
			).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

			target_color1 = Color(1, 1, 1)

			target_color2 = Color(1, 1, 1, 0)

			tw.parallel().tween_property(sprite.material_override, "shader_parameter/primary_color", target_color1, duration)
			tw.parallel().tween_property(sprite.material_override, "shader_parameter/secondary_color", target_color2, duration)
