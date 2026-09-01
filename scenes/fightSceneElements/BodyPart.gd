extends Node3D

@onready var myself : Array = [self]
@onready var parent_enemy = get_parent().get_parent()

@onready var animated_sprite_3D = $AnimatedSprite3D
@onready var selector_position = $SelectorPosition
@onready var collision_shape = $Area3D/CollisionShape3D

@onready var liveBarProgressBar = $LiveBar/SubViewport/Control/ProgressBar
@onready var liveBarNode = $LiveBar
@onready var liveDataLabel = $LiveBar/livedata
@onready var nameLabel = $LiveBar/Name
@onready var levelLabel = $LiveBar/Level

var local_life : float = 0.0
var local_defense : float = 0.0

var base_local_life : float = 0.0
var base_local_defense : float = 0.0
var body_part_is_main : bool = false

func setup(body_part_data, position_index, render_priority_index):
	await positions_and_collisions_setup(body_part_data, position_index, render_priority_index)
	await level_stats_scalling_setup(body_part_data.local_life, body_part_data.local_defense, body_part_data.main_body_part)
	animated_sprite_3D.set_collision_size()
	
	animated_sprite_3D.play("Idle")

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouse and Input.is_action_just_pressed("click"):
		select_body_part()

func get_marker_position(Type : String):
	return parent_enemy.get_marker_position(Type)

func get_damage(damage):
	await calculate_damage(damage)
	add_trauma(3)
		##var resource = DialogueManager.create_resource_from_text("~ start \n " + data["name"] + ": hola,soy un "+ data["name"] +"!")
		##DialogueManager.show_example_dialogue_balloon(resource, "start")
		##FIGHT_SCENE_PATH.battle_paused = true
		##await DialogueManager.dialogue_ended
		##FIGHT_SCENE_PATH.battle_paused = false
		##FIGHT_SCENE_PATH.turns()


func calculate_damage(brute_damage):
	var real_damage = brute_damage - local_defense
	
	if real_damage <= 0:
		real_damage = 0

	print(self.name + " | "+ "Daño bruto: " + str(brute_damage) + " Defensa local " + str(local_defense) + " Daño real " + str(real_damage))

	local_life -= real_damage

	if local_life <= 0:
		visible = false
		if body_part_is_main:
			parent_enemy.character_down()
			

	var message = str(brute_damage) + " - " + str(local_defense) + " = " + str(real_damage)
	point_score(message)

	print(self.name + " | "+ "A la parte: " +self.name +" le queda:  "+ str(local_life))
	update_life_bar()

func level_stats_scalling_setup(new_local_life, new_local_defense, new_local_level):
	if new_local_level:
		body_part_is_main = true
		levelLabel.text = " LV:"+str(int(parent_enemy.data["level"]))

	local_life = new_local_life + parent_enemy.data["level"]
	local_defense = new_local_defense + parent_enemy.data["level"]
	base_local_life = new_local_life + parent_enemy.data["level"]
	base_local_defense = new_local_defense + parent_enemy.data["level"]
	liveBarNode.position = selector_position.position
	update_life_bar()

func update_life_bar():
	nameLabel.text = self.name
	liveBarProgressBar.max_value = base_local_life
	liveBarProgressBar.value = local_life

	liveDataLabel.text = str(local_life)+"/"+str(base_local_life)

func positions_and_collisions_setup(body_part_data, position_index, render_priority_index):
	name = body_part_data.character.resource_name

	animated_sprite_3D.sprite_frames = body_part_data.character
	animated_sprite_3D.render_priority = render_priority_index 
	animated_sprite_3D.material_override = animated_sprite_3D.material_override.duplicate()
	
	animated_sprite_3D.material_override.render_priority = render_priority_index
	animated_sprite_3D.material_override.set_shader_parameter("texture_albedo", animated_sprite_3D.sprite_frames.get_frame_texture("Idle", 0))
	animated_sprite_3D.material_override.set_shader_parameter("outline_width", 1)

	collision_shape.shape = body_part_data.shape3D
	collision_shape.position = body_part_data.shape_position + Vector3(0, position_index, position_index)
	animated_sprite_3D.position += Vector3(0, position_index, position_index)

	selector_position.position = body_part_data.selector_point_position

func select_body_part():
	parent_enemy.get_parent().get_parent().selected_enemy(myself)
	animated_sprite_3D.add_to_group("SELECTARROW")
	animated_sprite_3D.material_override.set_shader_parameter("enable_outline", true)
	animated_sprite_3D.material_override.set_shader_parameter("outline_color", Color("ffff00"))

func above_body_part():
	animated_sprite_3D.material_override.set_shader_parameter("enable_outline", true)
	animated_sprite_3D.material_override.set_shader_parameter("outline_color", Color("ffffff"))

func above_body_part_quit():
	animated_sprite_3D.material_override.set_shader_parameter("enable_outline", false)

func _on_area_3d_mouse_entered() -> void:
	if !animated_sprite_3D.is_in_group("SELECTARROW"):
		above_body_part()

func _on_area_3d_mouse_exited() -> void:
	if !animated_sprite_3D.is_in_group("SELECTARROW"):
		above_body_part_quit()


@export var max_position_offset := Vector3(1, 1, 0.2)
@export var trauma_decay: float = 1

var trauma: float = 0.0
var time: float = 0.0

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - trauma_decay * delta, 0.0)
		time += delta * 30.0
		_apply_shake()

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _apply_shake() -> void:
	var shake := trauma * trauma
	
	# Aplica desplazamiento directo usando offset y rotación
	animated_sprite_3D.offset.x = randf_range(-1.0, 1.0) * max_position_offset.x * shake
	animated_sprite_3D.offset.y = randf_range(-1.0, 1.0) * max_position_offset.y * shake

const MESSAGE_SCENE = preload("res://in_game_message.tscn")

func point_score(message : String):
	var scene = MESSAGE_SCENE.instantiate()
	parent_enemy.add_child(scene)
	scene.position += Vector3(0, 0.3, 0.1)
	scene.setup(message)
