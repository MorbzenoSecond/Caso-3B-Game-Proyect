extends EventsScript
class_name DialogueEvent

func execute(body : CharacterBody3D, markers_position_array : Array):
	GameDataManager.MAIN.enter_event()
	
	body.target_pos = null 
	body.velocity = Vector3.ZERO
	DialogueManager.show_example_dialogue_balloon(Dialogues[0], "start", [body])
	await DialogueManager.dialogue_ended
	if !markers_position_array.is_empty():
		
		body.target_pos = markers_position_array[0]
		await body.nav_agent.navigation_finished

		DialogueManager.show_example_dialogue_balloon(Dialogues[1], "start", [body])
		await DialogueManager.dialogue_ended

		body.target_pos = markers_position_array[1]
		await body.nav_agent.navigation_finished

		body.target_pos = markers_position_array[2]

		DialogueManager.show_example_dialogue_balloon(Dialogues[2], "start", [body])
		await body.nav_agent.navigation_finished
		body.queue_free()

	GameDataManager.MAIN.exit_event()
