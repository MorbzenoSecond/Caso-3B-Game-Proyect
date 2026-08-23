class_name DashAction
extends EnemyAction

@export var DashSpeed : float = 0.0
var Boolean : bool = true

func execute(enemy):
	enemy.sprite.set_process(Boolean)
	Boolean = !Boolean
	enemy.CUSTOM_RUN_MAX_SPEED = DashSpeed
