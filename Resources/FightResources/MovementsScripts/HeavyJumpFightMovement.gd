class_name HeavyJumpMovement
extends FightMovements

func executed(self_node : Node3D, target_node: Node3D):
	var target_pos: Vector3 = target_node.get_marker_position("hit_position_1")
	var jump_height: float = 2.0 # Altura del salto
	var jump_time: float = 1.2    # Tiempo total en el aire (mitad subir, mitad caer)
	var half_jump: float = jump_time / 2.0

	var tween = target_node.create_tween()

	# --- 1. MOVIMIENTO HORIZONTAL (X y Z) ---
	# Avanza linealmente hacia el objetivo durante todo el salto
	tween.tween_property(self_node, "global_position:x", target_pos.x, jump_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.parallel().tween_property(self_node, "global_position:z", target_pos.z, jump_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	# --- 2. SALTO (Eje Y - Subida) ---
	# Sube perdiendo velocidad en la cima
	tween.parallel().tween_property(self_node, "global_position:y", self_node.original_position.y + jump_height, half_jump)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	# --- 3. CAÍDA Y IMPACTO (Eje Y - Caída Pesada) ---
	# Cae acelerando fuertemente (EASE_IN) para dar peso
	tween.chain().tween_property(self_node, "global_position:y", target_pos.y + 0.421, half_jump)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	# --- 4. IMPACTO Y ATAQUE ---
	# Daño al tocar suelo
	tween.tween_callback(self_node.FIGHT_SCENE_PATH.get_parent().get_parent().camera.add_trauma.bind(0.8))
	tween.tween_callback(self_node.attack_everyone.bind(self_node.FightResourceStats.base_damage))
	
	# Pausa breve en el suelo tras el choque para simular masa
	tween.tween_interval(0.15) 

	# --- 5. REGRESO ---
	tween.tween_property(self_node, "global_position", self_node.original_position, 0.8)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(self_node.FIGHT_SCENE_PATH.turns)
