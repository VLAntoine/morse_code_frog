extends Node2D

@onready var player_character = $PlayerCharacter
@onready var level: TileMapLayer = $Level1
@onready var ultrasound = $Ultrasound

func _ready() -> void:
	var cells = level.get_used_cells()
	for c in cells:
		if level.get_cell_tile_data(c).get_custom_data("start"):
			GameManager.set_player_init_position(c)
			break
	
	player_character.setup(GameManager.player_data)
	
	ultrasound.setup(GameManager.ultrasound_data)
