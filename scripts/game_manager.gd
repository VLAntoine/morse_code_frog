extends Node

signal player_move_succeeded
signal player_move_failed
signal player_fallen
signal player_initialized
signal chest_opened
signal level_won

const INPUT_ENUM = USignalData.InputValue

var ultrasound_data: UltrasoundData

var start_cell: Vector2i
var goal_cell: Vector2i
var chest_cell: Vector2i
var walls_cell: Array[Vector2i]
var holes_cell: Array[Vector2i]

var player_position: Vector2i
var player_flip := false

func _ready() -> void:
	ultrasound_data = UltrasoundData.new()
	ultrasound_data.input_set.connect(_on_input_set)
	ultrasound_data.setup()

func set_player_init_position(cell: Vector2i):
	start_cell = cell
	init_player_position(false)
	
func init_player_position(with_animation: bool = true):
	player_flip = false
	player_position = start_cell
	player_initialized.emit(with_animation)

func set_goal_cell(cell: Vector2i):
	goal_cell = cell

func set_chest_cell(cell: Vector2i):
	chest_cell = cell

func add_walls_cell(cell: Vector2i):
	walls_cell.append(cell)

func add_holes_cell(cell: Vector2i):
	holes_cell.append(cell)
	
func clear_cells_data():
	holes_cell = []
	walls_cell = []

func _on_input_set(ultrasound_inputs: Array[INPUT_ENUM]):
	var move := Vector2i(0,0)
	for inpt in ultrasound_inputs:
		match inpt:
			INPUT_ENUM.UP:
				move += Vector2i(0, -1)
			INPUT_ENUM.DOWN:
				move += Vector2i(0, 1)
			INPUT_ENUM.LEFT:
				player_flip = true
				move += Vector2i(-1, 0)
			INPUT_ENUM.RIGHT:
				player_flip = false
				move += Vector2i(1, 0)
	if move.x < 0:
		player_flip = true
	elif move.x > 0:
		player_flip = false
	
	emit_move(move)

func emit_move(move: Vector2i) -> void:
	var next_pos := player_position + move
	
	if move.length() < 2:
		if next_pos in walls_cell:
			player_move_failed.emit(next_pos)
			if next_pos == chest_cell:
				chest_opened.emit(next_pos)
				chest_cell = Vector2i(-1,-1)
		elif next_pos in holes_cell:
			player_fallen.emit(next_pos)
		else:
			player_move_succeeded.emit(next_pos)
			player_position = next_pos
			if player_position == goal_cell:
				clear_cells_data()
				level_won.emit()
	else:
		@warning_ignore("integer_division")
		var mid_pos := player_position + move/2
		if mid_pos in walls_cell:
			player_move_failed.emit(next_pos)
			if mid_pos == chest_cell:
				chest_opened.emit(mid_pos)
		elif next_pos in walls_cell:
			player_position = mid_pos
			player_move_failed.emit(next_pos)
			if next_pos == chest_cell:
				chest_opened.emit(next_pos)
			if mid_pos in holes_cell:
				player_fallen.emit(mid_pos)
		elif next_pos in holes_cell:
			player_fallen.emit(next_pos)
		else:
			player_move_succeeded.emit(next_pos)
			player_position = next_pos
			if player_position == goal_cell:
				clear_cells_data()
				level_won.emit()
