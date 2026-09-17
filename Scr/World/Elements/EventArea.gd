extends Area3D

@export var event_logic_script: Script # Arrastras el archivo .gd aquí
@export var dialogues: Array[DialogueResource]
@export var markers: Array[Node3D]
@export var TriggerKey : String

func _on_body_entered(body: Node3D) -> void:
	if body is WalkingNeutralInMap:
		if body.EventKey == TriggerKey:
			GameDataManager.MAIN.event_runner.execute_event(
				event_logic_script, 
				body, 
				markers, 
				dialogues
			)
