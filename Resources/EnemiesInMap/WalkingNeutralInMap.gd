extends WalkingNPCInMap

var target_pos 

func _process(delta: float) -> void:
	if player_is_in and Input.is_action_just_pressed("E"):
		DialogueManager.show_example_dialogue_balloon(Dialogue, "start", [self])
		

func _on_dialogue_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		$Label3D.text = "E"
		player_is_in = true

func _on_dialogue_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		$Label3D.text = ""
		player_is_in = false

func follow():
	for i in $RotableObjects/Areas/DialogueArea.get_overlapping_bodies():
		if i.is_in_group("PLAYER"):
			
			target_pos = i

func _physics_process(delta : float):
	super._physics_process(delta)
	if target_pos:
		
		basic_movement(delta)
		
		nav_agent.target_position = target_pos.global_position
		if nav_agent.distance_to_target() < 0.65:
			CUSTOM_RUN_MAX_SPEED = 0.0
			return
		CUSTOM_RUN_MAX_SPEED = stats.RUN_MAX_SPEED 
