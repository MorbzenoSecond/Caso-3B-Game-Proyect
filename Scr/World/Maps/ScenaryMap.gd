extends Node3D

class_name ScenaryMap

@export_group("Scenary Map", "scenary_")
@export var scenary_music : String = ""
@export var scenary_environment : Environment

@export_group("Scenary Fight", "scenary_")
@export var scenary_fight_ground : String = ""
@export var scenary_fight_music : String = ""

@onready var room_name = self.name
@onready var conections = get_node_or_null("Conections")
@onready var marcador = get_node_or_null("Elements").get_node_or_null("SavePoint")

func prepare_fight_scenary(enemy_data, enemy_nodes):
	GameDataManager.MAIN.start_fight(enemy_data, scenary_fight_ground, scenary_fight_music, enemy_nodes)

const TILE_SET = preload("res://new_tile_set.tres")

func create_map():
	var grid_map = $GridMaps/NavigationRegion3D/GridMap
	var parent_node = GameDataManager.MAIN.mini_map.maps
	var layers_by_y: Dictionary = {}

	var base = Control.new()
	base.name = self.name 
	parent_node.add_child(base)
	base.position = Vector2(position.x, position.z) * 50

	for i in grid_map.get_used_cells():
		var y_level: int = i.y
		
		if not layers_by_y.has(y_level):
			var layer = TileMapLayer.new()
			layer.name = "Layer_Y_" + str(y_level)
			layer.tile_set = TILE_SET
			layers_by_y[y_level] = layer
		
		var layer: TileMapLayer = layers_by_y[y_level]
		var cell_2d = Vector2i(i.x, i.z)
		var atlas_coords = Vector2i(max(0, y_level), 0)
		
		layer.set_cell(cell_2d, 0, atlas_coords)

	layers_by_y.sort()

	for layer in layers_by_y:
		base.add_child(layers_by_y[layer])
	var MAPMUSTSELECT = get_tree().get_nodes_in_group("MAPMUSTSELECT")
	
	for i in MAPMUSTSELECT:
		if i.get_parent().get_parent() == self:
			var sprite = Sprite2D.new()
			sprite.texture = load("res://Assets/Art/2DSprites/flecha.png")
			base.add_child(sprite)
			sprite.position = Vector2(i.global_position.x,i.global_position.z) * 50 

func get_spawn_point() -> Vector3 :
	if marcador:
		print_rich("[color=green][b]Hello world![/b][/color]")
		return marcador.get_node("Marker3D").global_position
	return Vector3(0,0,0)
