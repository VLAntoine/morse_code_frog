extends Node

var ultrasound_data: UltrasoundData
var player_data: PlayerData

func _ready() -> void:
	ultrasound_data = UltrasoundData.new()
	ultrasound_data.input_set.connect(_on_input_set)
	
	player_data = PlayerData.new()

func _on_input_set(ultrasound_input: UltrasoundData.InputValue):
	match ultrasound_input:
		UltrasoundData.InputValue.UP:
			player_data.move_up()
		UltrasoundData.InputValue.DOWN:
			player_data.move_down()
		UltrasoundData.InputValue.LEFT:
			player_data.move_left()
		UltrasoundData.InputValue.RIGHT:
			player_data.move_right()
