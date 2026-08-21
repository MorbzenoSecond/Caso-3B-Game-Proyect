extends Camera3D

@export var max_position_offset := Vector3(0.5, 0.5, 0.2)
@export var max_rotation_offset := Vector3(0.05, 0.05, 0.05) # En radianes
@export var trauma_decay: float = 1.8 # Velocidad a la que se reduce el temblor

var trauma: float = 0.0
var time: float = 0.0
var initial_rotation: Vector3

func _ready() -> void:
	initial_rotation = rotation

func _process(delta: float) -> void:
	if trauma > 0.0:
		# Reduce el trauma con el tiempo
		trauma = max(trauma - trauma_decay * delta, 0.0)
		time += delta * 30.0
		_apply_shake()
	else:
		# Restaura la rotación original suavemente cuando termina
		rotation = rotation.lerp(initial_rotation, delta * 10.0)

# Llama a esta función para activar la sacudida (ej. add_trauma(0.8))
func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _apply_shake() -> void:
	# Elevar al cuadrado el trauma genera una caída no lineal mucho más natural
	var shake := trauma * trauma
	
	# Aplica desplazamiento directo usando offset y rotación
	h_offset = randf_range(-1.0, 1.0) * max_position_offset.x * shake
	v_offset = randf_range(-1.0, 1.0) * max_position_offset.y * shake
	
	rotation.z = initial_rotation.z + randf_range(-1.0, 1.0) * max_rotation_offset.z * shake
