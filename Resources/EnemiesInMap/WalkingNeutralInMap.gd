extends WalkingNPCInMap
class_name WalkingNeutralInMap


@export var EventKey : String

var target_pos 

func _ready() -> void:
	super.set_sprite_frames()

func _process(delta: float) -> void:
	if player_is_in and Input.is_action_just_pressed("E"):
		event_data.event_script.execute(self,[])

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

func unfollow():
	target_pos = null

func _physics_process(delta : float):
	super._physics_process(delta)
	if target_pos:
		nav_agent.target_position = target_pos.global_position
		basic_movement(delta)
		if nav_agent.distance_to_target() < 0.1:
			CUSTOM_RUN_MAX_SPEED = 0.0
			return
		CUSTOM_RUN_MAX_SPEED = stats.RUN_MAX_SPEED 
