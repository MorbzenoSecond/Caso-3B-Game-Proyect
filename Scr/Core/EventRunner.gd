extends Node3D
class_name EventRunner

signal event_started
signal event_finished

func execute_event(event_script: Script, body: CharacterBody3D, markers: Array, dialogues: Array[DialogueResource]) -> void:
	if not event_script:
		push_warning("No se asignó ningún script de evento.")
		return

	event_started.emit()
	
	var logic_instance: EventLogic = event_script.new()
	
	logic_instance.run(body, markers, dialogues)
	
	event_finished.emit()
