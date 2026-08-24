extends Node3D

@onready var myself : Array = [self]
@onready var parent_enemy = get_parent().get_parent()

var local_life : float = 0.0

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		#print($Area3D/CollisionShape3D.shape.resource_name)
		parent_enemy.get_parent().get_parent().selected_enemy(myself)

func get_marker_position(Type : String):
	return parent_enemy.get_marker_position(Type)

func get_damage(damage):
	local_life -= damage
	print(local_life)
	if local_life <= 0:
		visible = false
	parent_enemy.true_live -= damage
	parent_enemy.liveBar.value = parent_enemy.true_live
	parent_enemy.liveDataLabel.text = str(parent_enemy.true_live) +"/"+str(parent_enemy.max_live)
	if parent_enemy.true_live <= 0:
		#$AnimatedSprite2D.animation = "Death"
		parent_enemy.FIGHT_SCENE_PATH.update_characters_in_fight(parent_enemy)
		##var resource = DialogueManager.create_resource_from_text("~ start \n " + data["name"] + ": hola,soy un "+ data["name"] +"!")
		##DialogueManager.show_example_dialogue_balloon(resource, "start")
		##FIGHT_SCENE_PATH.battle_paused = true
		##await DialogueManager.dialogue_ended
		##FIGHT_SCENE_PATH.battle_paused = false
		##FIGHT_SCENE_PATH.turns()
#
		#return
	#if $AnimatedSprite2D.animation == "Idle":
		#$AnimatedSprite2D.animation = "Punched"

#func _on_animated_sprite_2d_animation_finished() -> void:
	#if $AnimatedSprite2D.animation == "Punched":
		#$AnimatedSprite2D.play("Idle")
