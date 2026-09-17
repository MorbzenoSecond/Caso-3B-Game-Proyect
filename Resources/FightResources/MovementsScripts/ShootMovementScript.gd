class_name ShootMovement
extends FightMovements

@export var ShootType : PackedScene 
@export var ShootSpeed: float = 2.0
@export var VisualEffect : Array[PackedScene]

func executed(self_node : Node3D, target_node: Array):
	var tween : Tween = self_node.create_tween()
	tween.tween_property(self_node, "global_position:x", target_node[0].get_marker_position("hit_position_3").x, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self_node, "global_position:z", target_node[0].get_marker_position("hit_position_3").z, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_callback(self_node.attack.bind(self_node.FightResourceStats.base_damage, target_node[0]))
	tween.tween_callback(shoot.bind(self_node.global_position.direction_to(target_node[0].global_position), self_node))

	tween.tween_property(self_node, "global_position", self_node.original_position, 1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(self_node.FIGHT_SCENE_PATH.turns)

func shoot(direction, self_node):
	var scene = ShootType.instantiate()
	GameDataManager.MAIN.dumpster.add_child(scene)
	
	for node in VisualEffect:
		var effect = node.instantiate()
		scene.get_node("VisualEffect").add_child(effect)

	scene.global_position = self_node.get_node("Marker3D").global_position
	
	scene.direction = direction
	scene.node = self
