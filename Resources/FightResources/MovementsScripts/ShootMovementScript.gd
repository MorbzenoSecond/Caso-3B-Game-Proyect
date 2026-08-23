
class_name ShootMovement
extends FightMovements

@export var ShootType : PackedScene 
@export var ShootSpeed: float = 2.0
@export var VisualEffect : Array[PackedScene]

func executed(self_node : Node3D, target_node: Node3D):
	
	var tween : Tween = self_node.create_tween()
	tween.tween_property(self_node, "global_position:x", target_node.get_marker_position("hit_position_3").x, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self_node, "global_position:z", target_node.get_marker_position("hit_position_3").z, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_callback(self_node.attack.bind(self_node.FightResourceStats.base_damage, target_node))
	tween.tween_callback(shoot.bind(self_node.global_position.direction_to(target_node.global_position), self_node))

	print(self_node.original_position)
	tween.tween_property(self_node, "global_position", self_node.original_position, 1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(self_node.FIGHT_SCENE_PATH.turns)

func shoot(direction, self_node):
	var scene = ShootType.instantiate()
	GameDataManager.MAIN.Dumpster.add_child(scene)
	
	for node in VisualEffect:
		var effect = node.instantiate()
		scene.get_node("VisualEffect").add_child(effect)
		
	self_node.get_parent().add_child(scene)
	
	scene.global_position = self_node.get_node("Marker3D").global_position
	
	scene.direction = direction
	scene.node = self
	var flare_tex = self_node.get_node("Marker3D").get_node("Sprite3D").material_override.get_shader_parameter("flare_texture")

	if flare_tex and flare_tex is GradientTexture2D:
		var grad: Gradient = flare_tex.gradient
		
		if grad.get_point_count() > 0:
			tween(self_node)

func tween(self_node):
	#$AudioStreamPlayer3D2.play()
	var sprite = self_node.get_node("Marker3D").get_node("Sprite3D")
	if sprite.material_override:
		sprite.material_override = sprite.material_override.duplicate()
	var flare_tex = sprite.material_override.get_shader_parameter("flare_texture")

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
			
			#var tw = create_tween()
#
			#tw.tween_method(
				#func(val: float): grad.set_offset(1, val),
				#initial_offset,
				#target_offset,
				#duration
			#).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			#
			#target_color1 = Color(0, 0, 0) 
			#target_color2 = Color(0, 0, 0) 
			#
			#tw.parallel().tween_property(sprite.material_override, "shader_parameter/primary_color", target_color1, duration)
			#tw.parallel().tween_property(sprite.material_override, "shader_parameter/secondary_color", target_color2, duration)
