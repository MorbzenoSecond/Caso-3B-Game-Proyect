extends Area2D

@export var enemy = "string"
@export var speed : int = 0
@onready var sprite = $AnimatedSprite2D
@export var level : int = 1
@export var life : float = 10

var enemy_data : = {}
# Called when the node enters the scene tree for the first time.
var player_is_in : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_data = { 
		enemy :{
			"speed" : speed,
			"level" : level,
			"life"  : life
		}
	}
	$AnimatedSprite2D.play(enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_is_in and Input.is_action_just_pressed("ui_accept"):
		get_parent().prepare_fight_scenary(enemy_data)

func _on_area_entered(area: Area2D) -> void:
	player_is_in = true

func _on_area_exited(area: Area2D) -> void:
	player_is_in = false
