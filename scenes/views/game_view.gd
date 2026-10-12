extends Node2D

@onready var player_character = $PlayScreenControl/PlayerCharacter
@onready var level_control: Control = $PlayScreenControl/LevelControl
@onready var ultrasound = $Ultrasound

var levels_scenes: Array[Resource] = [
	preload("res://scenes/components/levels/level_1.tscn"),
	preload("res://scenes/components/levels/level_2.tscn")
]

var current_level_index := -1

func _ready() -> void:
	GameManager.level_won.connect(_on_level_won)
	player_character.setup()
	ultrasound.setup(GameManager.ultrasound_data)
	next_level()
	
func next_level() -> void:
	if level_control.get_child_count() > 0:
		var current_level = level_control.get_child(0)
		level_control.remove_child(current_level)
		current_level.queue_free()
	
	current_level_index += 1
	var new_level = levels_scenes[current_level_index].instantiate()
	level_control.add_child(new_level)
	set_game_manager_map_data(new_level)

func set_game_manager_map_data(level: TileMapLayer) -> void:
	var cells = level.get_used_cells()
	for c in cells:
		if level.get_cell_tile_data(c).get_custom_data("start"):
			GameManager.set_player_init_position(c)
		elif level.get_cell_tile_data(c).get_custom_data("end"):
			GameManager.set_goal_cell(c)
		elif level.get_cell_tile_data(c).get_custom_data("wall"):
			GameManager.add_walls_cell(c)
		elif level.get_cell_tile_data(c).get_custom_data("hole"):
			GameManager.add_holes_cell(c)

func _on_level_won() -> void:
	next_level()
