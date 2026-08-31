extends WalkingNPCInMap

@onready var target_pos = $"../../MainCharacterWorld"

func _ready() -> void:
	super.set_sprite_frames()


func _physics_process(delta : float):
	super._physics_process(delta)
	
	nav_agent.target_position = target_pos.global_position
	basic_movement(delta)
	if nav_agent.distance_to_target() < 0.65:
		CUSTOM_RUN_MAX_SPEED = 0.0
		return
	CUSTOM_RUN_MAX_SPEED = stats.RUN_MAX_SPEED 
