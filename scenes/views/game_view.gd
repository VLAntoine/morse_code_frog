extends Node2D

@onready var player_character = $PlayerCharacter
@onready var level: TileMapLayer = $Level1
@onready var ultrasound = $Ultrasound

func _ready() -> void:
	var cells = level.get_used_cells()
	for c in cells:
		if level.get_cell_tile_data(c).get_custom_data("start"):
			GameManager.set_player_init_position(c)
		elif level.get_cell_tile_data(c).get_custom_data("end"):
			GameManager.set_goal_cell(c)
		elif level.get_cell_tile_data(c).get_custom_data("wall"):
			GameManager.add_walls_cell(c)
	
	player_character.setup()
	ultrasound.setup(GameManager.ultrasound_data)
