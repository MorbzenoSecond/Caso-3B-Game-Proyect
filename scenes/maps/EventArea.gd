extends Area3D

@export var event_data : EventsResource
@export var TriggerKey : String

func _on_body_entered(body: Node3D) -> void:
	if body is WalkingNeutralInMap:
		if body.EventKey == TriggerKey:
			event_data.event_script.execute(body, $Markers.get_children())
