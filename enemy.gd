extends Area2D

@export var enemy = "string"
@onready var sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
var player_is_in : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play(enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_is_in and Input.is_action_just_pressed("ui_accept"):
		get_parent().get_parent().get_parent().start_fight(enemy)


func _on_area_entered(area: Area2D) -> void:
	player_is_in = true


func _on_area_exited(area: Area2D) -> void:
	player_is_in = false
