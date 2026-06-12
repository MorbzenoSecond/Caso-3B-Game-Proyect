extends Node2D

@onready var sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("ingrese")
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	$AnimationPlayer.play_backwards("ingrese")
	get_parent().get_parent().finish_fight()
	$Area2D/CollisionShape2D.disabled = true
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().paused = false
