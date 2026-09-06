class_name DirectPunchMovement
extends FightMovements

func executed(self_node : Node3D, target_node: Array):
	var tween : Tween = self_node.create_tween()
	tween.tween_property(self_node, "global_position:x", target_node[0].get_marker_position("hit_position_1").x, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self_node, "global_position:z", target_node[0].get_marker_position("hit_position_1").z, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(self_node.attack.bind(self_node.true_damage, target_node[0]))

	tween.tween_property(self_node, "global_position", self_node.original_position, 1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(self_node.FIGHT_SCENE_PATH.turns)
