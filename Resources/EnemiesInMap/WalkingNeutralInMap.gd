extends WalkingNPCInMap

func _process(delta: float) -> void:
	if player_is_in and Input.is_action_just_pressed("click"):
		GameDataManager.create_dialogue(Dialogue)

func _on_dialogue_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		player_is_in = true

func _on_dialogue_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		player_is_in = false
