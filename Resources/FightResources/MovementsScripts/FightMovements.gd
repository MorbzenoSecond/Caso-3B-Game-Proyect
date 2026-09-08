class_name FightMovements
extends Resource

@export var all_targets : bool = false
@export var not_targets : bool = false
@export var can_only_target_himself : bool = false
@export var can_only_target_alies : bool = false
@export var can_only_target_enemies : bool = false

# Esta función la ejecutará el enemigo cuando active la acción
func execute(_self_node, _enemy: Node3D) -> void:
	pass
