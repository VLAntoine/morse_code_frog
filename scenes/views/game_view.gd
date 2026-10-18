extends Node2D

const SHUTTER_UP_POS_Y := -120.0
const SHUTTER_DOWN_POS_Y := 8.0

@onready var player_character = $PlayScreenControl/PlayerCharacter
@onready var level_control: Control = $PlayScreenControl/LevelControl
@onready var ultrasound = $Ultrasound
@onready var controller = $Controller
@onready var roller_shutter = $RollerShutterTextureRect
@onready var new_button_sprite = $NewButtonSprite
@onready var win_sprite = $WinSprite

@onready var chest_audio = $ChestAudioStreamPlayer
@onready var shutter_down = $ShutterDownAudioStreamPlayer
@onready var main_audio = $MainThemeAudioStreamPlayer
@onready var shutter_open_audio = $ShutterOpenAudioStreamPlayer


var levels_scenes: Array[Resource] = [
	#preload("res://scenes/components/levels/level_test.tscn"),
	preload("res://scenes/components/levels/level_1.tscn"),
	preload("res://scenes/components/levels/level_2.tscn"),
	preload("res://scenes/components/levels/level_3.tscn"),
	preload("res://scenes/components/levels/level_4.tscn"),
	preload("res://scenes/components/levels/level_5.tscn")
]

var current_level_index := -1

func _ready() -> void:
	new_button_sprite.visible = false
	new_button_sprite.stop()
	
	win_sprite.visible = false
	win_sprite.stop()
	
	main_audio.play()
	
	GameManager.level_won.connect(_on_level_won)
	GameManager.chest_opened.connect(_on_chest_opened)
	roller_shutter.position.y = SHUTTER_DOWN_POS_Y
	player_character.setup()
	ultrasound.setup(GameManager.ultrasound_data)
	controller.setup(GameManager.ultrasound_data)
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
	player_character.animated_sprite.scale = Vector2(1,1)
	await roller_shutter_up()
	await player_character.first_player_init()
	ultrasound.disabled = false

func set_game_manager_map_data(level: TileMapLayer) -> void:
	var cells = level.get_used_cells()
	for c in cells:
		if level.get_cell_tile_data(c).get_custom_data("start"):
			GameManager.set_player_init_position(c)
		elif level.get_cell_tile_data(c).get_custom_data("end"):
			GameManager.set_goal_cell(c)
		elif level.get_cell_tile_data(c).get_custom_data("wall"):
			GameManager.add_walls_cell(c)
			if level.get_cell_tile_data(c).get_custom_data("to_open"):
				GameManager.set_chest_cell(c)
		elif level.get_cell_tile_data(c).get_custom_data("hole"):
			GameManager.add_holes_cell(c)

func _on_level_won() -> void:
	ultrasound.disabled = true
	await player_character.player_win()
	if current_level_index < len(levels_scenes) - 1:
		await roller_shutter_down()
		await next_level()
	else:
		win_sprite.visible = true
		win_sprite.play()

func _on_chest_opened(cell: Vector2i) -> void:
	ultrasound.disabled = true
	chest_audio.play()
	var level: TileMapLayer = level_control.get_child(0)
	level.set_cell(cell,3,Vector2i(13,0))
	await new_button_owned()
	ultrasound.disabled = false

func roller_shutter_down() -> void:
	roller_shutter.position.y = SHUTTER_UP_POS_Y
	shutter_down.play()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_DOWN_POS_Y,0.5)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_DOWN_POS_Y-16,0.2)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_DOWN_POS_Y,0.2)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_DOWN_POS_Y-4,0.1)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_DOWN_POS_Y,0.1)
	tween.tween_interval(1.0)
	await tween.finished

func roller_shutter_up() -> void:
	roller_shutter.position.y = SHUTTER_DOWN_POS_Y
	shutter_open_audio.play()
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(roller_shutter,"position:y",SHUTTER_UP_POS_Y,1.0)
	await tween.finished

func new_button_owned() -> void:
	new_button_sprite.visible = true
	new_button_sprite.play()
	var tween = create_tween()
	tween.tween_interval(2.0)
	await tween.finished
	new_button_sprite.visible = false
	new_button_sprite.stop()
	
