class_name UltrasoundData
extends Node

signal input_set

var usignals_data: Array[USignalData] = []

func setup() -> void:
	add_new_signal()
	add_new_signal()

func add_new_signal() -> void:
	var usig_data = USignalData.new()
	usignals_data.append(usig_data)

func start_wave(i: int) -> void:
	if i < len(usignals_data):
		usignals_data[i].start_wave()
		for usig_d in usignals_data:
			usig_d.ultrasound_started = true

func update_last_wave(i: int, delta: float) -> void:
	if i < len(usignals_data):
		usignals_data[i].update_last_wave(delta)

func stop_wave(i: int) -> void:
	if i < len(usignals_data):
		usignals_data[i].stop_wave()

func clear_signals() -> void:
	var inputs : Array[USignalData.InputValue] = []
	for u in usignals_data:
		inputs.append(u.get_input_value())
		u.clear_wave()
	input_set.emit(inputs)
