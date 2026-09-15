extends Node

@export var initial_state:State

var current_state : State = null
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.parent = get_parent()
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
		if state != current_state:
			return
		var new_state = states.get(new_state_name.to_lower())
		if !new_state:
			return
		if current_state:
			current_state.Exit()
		new_state.Enter()
		current_state = new_state

func change_state(new_state_name: String) -> void:
	new_state_name = new_state_name.to_lower()
	var new_state = states.get(new_state_name)
	if !new_state:
		push_error("STATE MACHINE: El estado '%s' no existe." % new_state_name)
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state
