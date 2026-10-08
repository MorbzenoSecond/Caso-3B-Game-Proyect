extends EventLogic

func run(body: CharacterBody3D, markers: Array, dialogues: Array[DialogueResource]) -> void:
	GameDataManager.MAIN.bars_control.play("Enter")
	GameDataManager.MAIN.MainCharacter.is_active = false
	body.target_pos = null 
	body.velocity = Vector3.ZERO
	
	if not dialogues.is_empty():
		DialogueManager.show_example_dialogue_balloon(dialogues[0], "start", [body])
		await DialogueManager.dialogue_ended
	
	if not markers.is_empty():
		body.target_pos = markers[0]
		await body.nav_agent.target_reached
		body.velocity = Vector3.ZERO

		if dialogues.size() > 1:
			DialogueManager.show_example_dialogue_balloon(dialogues[1], "start", [body])
			await DialogueManager.dialogue_ended

		if markers.size() > 1:
			body.target_pos = markers[1]
			await body.nav_agent.target_reached
			body.velocity = Vector3.ZERO

		if dialogues.size() > 2:
			body.target_pos = markers[2]
			DialogueManager.show_example_dialogue_balloon(dialogues[2], "start", [body])
			await body.nav_agent.target_reached

		body.queue_free()
	GameDataManager.MAIN.MainCharacter.is_active = true
	GameDataManager.MAIN.bars_control.play_backwards("Enter")
