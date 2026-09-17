extends Sprite3D

@onready var energy_process_bar = $SubViewport/Control/Energy/ProgressBar
@onready var energy_texture_process_bar = $SubViewport/Control/Energy/TextureProgressBar
@onready var health_process_bar = $SubViewport/Control/Health/ProgressBar
@onready var health_texture_process_bar = $SubViewport/Control/Health/TextureProgressBar

@onready var live_data_label = $livedata
@onready var energy_data_label = $energy_label
@onready var name_label = $Name
@onready var level_label = $Level
@onready var energy_control = $SubViewport/Control/Energy


var progress_bar_tween : Tween

func setup(local_life, base_local_life):
	name_label.text = get_parent().name
	level_label.text = " LV:"+str(int(get_parent().parent_enemy.data["level"]))
	
	health_process_bar.max_value = base_local_life
	health_process_bar.value = local_life
	
	health_texture_process_bar.max_value = base_local_life
	health_texture_process_bar.value = local_life
	
	live_data_label.text = str(local_life)+"/"+str(base_local_life)

func setup_energy(true_energy_capacity, actual_energy_capacity):
	energy_process_bar.max_value = true_energy_capacity
	get_parent().parent_enemy.actual_energy_capacity = actual_energy_capacity
	
	progress_bar_alterate(actual_energy_capacity, energy_process_bar)
	energy_data_label.text = str(actual_energy_capacity) +"/"+ str(true_energy_capacity)
	
	energy_texture_process_bar.max_value = true_energy_capacity
	energy_texture_process_bar.value = actual_energy_capacity

func update_progress_bar(true_energy_capacity, true_energy_recuperation,actual_energy_capacity):
	actual_energy_capacity += true_energy_recuperation
	
	if actual_energy_capacity >= true_energy_capacity:
		actual_energy_capacity = true_energy_capacity
	
	get_parent().parent_enemy.actual_energy_capacity = actual_energy_capacity
	
	energy_process_bar.value = actual_energy_capacity
	energy_data_label.text = str(actual_energy_capacity) +"/"+ str(true_energy_capacity)

	energy_texture_process_bar.max_value = true_energy_capacity
	energy_texture_process_bar.value = actual_energy_capacity

func show_energy_usage(actual_energy_capacity):
	progress_bar_animation()
	var how_can_afffect_ussage = actual_energy_capacity - get_parent().parent_enemy.selected_attack.energy_consumtion
	energy_process_bar.value = how_can_afffect_ussage

func update_life_bar(local_life, base_local_life):
	health_process_bar.value = local_life

	live_data_label.text = str(local_life)+"/"+str(base_local_life)
	progress_bar_alterate(local_life,health_texture_process_bar)

func progress_bar_animation():
	energy_texture_process_bar.modulate = Color("ffffff")
	if progress_bar_tween:
		if progress_bar_tween.is_running():
			progress_bar_tween.kill()

	progress_bar_tween = create_tween().set_loops()
	progress_bar_tween.set_trans(Tween.TRANS_CUBIC)
	progress_bar_tween.set_ease(Tween.EASE_OUT)    
	
	progress_bar_tween.tween_property(energy_texture_process_bar, "modulate", Color("ffffff47"), 0.5)
	progress_bar_tween.tween_property(energy_texture_process_bar, "modulate", Color("ffffff"), 0.5)

func progress_bar_alterate(new_value : float,texture_process_bar):
	texture_process_bar.modulate = Color("ffffff")
	if progress_bar_tween:
		if progress_bar_tween.is_running():
			progress_bar_tween.kill()

	progress_bar_tween = create_tween()
	progress_bar_tween.set_trans(Tween.TRANS_CUBIC)
	progress_bar_tween.set_ease(Tween.EASE_OUT)    
	
	progress_bar_tween.tween_property(texture_process_bar, "value", new_value, 3.25)
