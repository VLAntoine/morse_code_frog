extends Node2D

@onready var player_character = $PlayerCharacter
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var ultrasound = $Ultrasound

func _ready() -> void:
	player_character.setup(GameManager.player_data)
	ultrasound.setup(GameManager.ultrasound_data)
