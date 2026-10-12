extends Node

signal player_position_changed
signal player_move_failed
signal player_fallen

var ultrasound_data: UltrasoundData

var start_cell: Vector2i
var goal_cell: Vector2i
var walls_cell: Array[Vector2i]
var holes_cell: Array[Vector2i]

var player_position: Vector2i:
	set(new_pos):
		if player_position != new_pos:
			player_position = new_pos
			player_position_changed.emit()

func _ready() -> void:
	ultrasound_data = UltrasoundData.new()
	ultrasound_data.input_set.connect(_on_input_set)

func set_player_init_position(cell: Vector2i):
	start_cell = cell
	init_player_position()

func init_player_position():
	player_position = start_cell

func set_goal_cell(cell: Vector2i):
	goal_cell = cell

func add_walls_cell(cell: Vector2i):
	walls_cell.append(cell)

func add_holes_cell(cell: Vector2i):
	holes_cell.append(cell)

func _on_input_set(ultrasound_input: UltrasoundData.InputValue):
	var next_pos := player_position
	match ultrasound_input:
		UltrasoundData.InputValue.UP:
			next_pos = player_position + Vector2i(0, -1)
		UltrasoundData.InputValue.DOWN:
			next_pos = player_position + Vector2i(0, 1)
		UltrasoundData.InputValue.LEFT:
			next_pos = player_position + Vector2i(-1, 0)
		UltrasoundData.InputValue.RIGHT:
			next_pos = player_position + Vector2i(1, 0)
	if next_pos in walls_cell:
		player_move_failed.emit(next_pos)
	elif next_pos in holes_cell:
		player_fallen.emit(next_pos)
	else:
		player_position = next_pos
		if player_position == goal_cell:
			print("WIN")
