extends Node3D

@export_group("Configuración de Bamboleo")
## Intensidad de rotación en grados (Pitch/Yaw/Roll)
@export var intensity: Vector3 = Vector3(0.8, 1.2, 0.5) 
## Velocidad a la que cambia el movimiento (frecuencia)
@export var frequency: float = 1.5 

var noise: FastNoiseLite
var time: float = 0.0

func _ready() -> void:
	# Configurar el generador de ruido
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi() # Semilla aleatoria cada vez que inicia

func _process(delta: float) -> void:
	time += delta * frequency
	
	# Muestreamos el ruido en 3 puntos distintos para cada eje de rotación
	var pitch = noise.get_noise_1d(time) * deg_to_rad(intensity.x)
	var yaw   = noise.get_noise_1d(time + 100.0) * deg_to_rad(intensity.y)
	var roll  = noise.get_noise_1d(time + 200.0) * deg_to_rad(intensity.z)
	
	# Aplicamos la rotación
	rotation = Vector3(pitch, yaw, roll)
