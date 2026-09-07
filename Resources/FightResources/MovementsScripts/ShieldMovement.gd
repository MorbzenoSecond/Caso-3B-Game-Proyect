class_name ShieldMovement
extends FightMovements

func executed(self_node : Node3D, target_node: Array):
	var tween : Tween = self_node.create_tween()

	tween.tween_callback(self_node.provoque)

	tween.tween_callback(self_node.FIGHT_SCENE_PATH.turns)
