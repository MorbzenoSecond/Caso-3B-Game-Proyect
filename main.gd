extends Node2D

const FIGHT_SCENE = preload("res://fight_scene.tscn")
func start_fight(animation):
	print(animation)
	$AnimationPlayer.play("new_animation")
	instanciate_fight(animation)
	get_tree().paused = true

func instanciate_fight(animation):
	var scene = FIGHT_SCENE.instantiate()
	scene.get_node("AnimatedSprite2D").play(animation)
	$NodoDePelea.add_child(scene)

func finish_fight():
	$AnimationPlayer.play_backwards("new_animation")
	$Timer.start()

func _on_timer_timeout() -> void:
	for i in $NodoDePelea.get_children():
		i.queue_free()
