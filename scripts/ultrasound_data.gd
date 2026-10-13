class_name UltrasoundData
extends Node

signal input_set

var usignals_data: Array[USignalData] = []

func setup() -> void:
	add_new_signal()

func add_new_signal() -> void:
	var usig_data = USignalData.new()
	usig_data.timeout_reached.connect(_on_timeout_reached)
	usignals_data.append(usig_data)

func start_wave(i: int) -> void:
	if i < len(usignals_data):
		usignals_data[i].start_wave()

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

func _on_timeout_reached() -> void:
	var end_ultrasound = true
	for u in usignals_data:
		if !u.timeout:
			end_ultrasound = false
	if end_ultrasound:
		clear_signals()
