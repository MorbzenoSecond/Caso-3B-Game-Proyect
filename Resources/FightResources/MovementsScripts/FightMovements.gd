class_name FightMovements
extends Resource


@export var damage_multiplicator : float = 1.0
@export var energy_consumtion : float = 1.0

@export var attack_target: attackTarget = attackTarget.can_only_target_enemies
enum attackTarget {
	can_only_target_enemies, 
	can_target_all_enemies, 
	can_only_target_himself, 
	can_only_target_allies, 
	can_target_all_allies,
	can_target_everybody
}

@export var attack_effect: attackEffect = attackEffect.neutral
enum attackEffect {
	neutral, 
	fire, 
	chaos, 
	electricity
}

@export var movement_icon : CompressedTexture2D

func execute(_effect, _self_node, _enemy: Node3D) -> void:
	pass
