@tool
extends WalkingNPCInMap
class_name WalkingEnemyInMap

@onready var shoot_shader = $RotableObjects/Marker3D/Sprite3D
@onready var id = str(global_position)
@onready var enemy_data_to_fight = stats.enemy_data["Enemies"].duplicate()

var enemy_dictionary_to_fight : Dictionary
var enemies_nodes_involucrated : Array
var _random_position = null
var target_pos 
var has_target : bool = false

func _ready() -> void:
	CreateTimersForSpecialActions()
	super.set_sprite_frames()
	await get_tree().process_frame
	original_position = global_position

func prepare_fight():
	prepare_fight_data()
	get_parent().get_parent().prepare_fight_scenary(enemy_dictionary_to_fight, enemies_nodes_involucrated)

func prepare_fight_data():
	var processed_body := []

	for enemy in $RotableObjects/Areas/UndetectedArea3D.get_overlapping_bodies():
		
		if enemy == self:
			enemies_nodes_involucrated.append(enemy)
			continue

		if enemy is WalkingEnemyInMap and enemy not in processed_body:
			enemies_nodes_involucrated.append(enemy)
			processed_body.append(enemy)

			for data in enemy.enemy_data_to_fight:
				enemy_data_to_fight.append(data)
	
	enemy_dictionary_to_fight["Enemies"] = enemy_data_to_fight

func CreateTimersForSpecialActions():
	for i in stats.SpecialActions:
		var NewTimer : Timer = Timer.new()
		$StateMachine/Chase.add_child(NewTimer)

		NewTimer.name =  str("NewTimer"+ i.resource_path.get_file().get_basename())

		NewTimer.wait_time = i.CoolDown
		NewTimer.timeout.connect($StateMachine/Chase._on_special_action_timeout.bind(i))

##region Process Region
#func _process(_delta: float) -> void:
#
	#$Label3D.text = $StateMachine.current_state.name
##endregion

#region area collisions Region
func _on_character_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		prepare_fight()
		player_is_in = true

func _on_character_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		player_is_in = false

func _on_detection_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		target_pos = body
		if stats.SmartEnemy:
			emit_alert()
		has_target = true

func _on_undetected_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		has_target = false
#endregion

func emit_alert():
	var processed_body := []
	for enemy in $RotableObjects/Areas/UndetectedArea3D.get_overlapping_bodies():
		
		if enemy == self:
			continue

		if enemy is WalkingEnemyInMap and enemy not in processed_body:
			enemy.target_pos = target_pos
			enemy.has_target= true
