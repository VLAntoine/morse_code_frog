class_name UltrasoundData
extends Node

signal input_set
signal wave_started
signal wave_stopped
signal new_signal_added

var usignals_data: Array[USignalData] = []

func setup() -> void:
	GameManager.chest_opened.connect(_on_chest_opened)
	add_new_signal()

func add_new_signal() -> void:
	var usig_data = USignalData.new()
	usignals_data.append(usig_data)

func start_wave(i: int) -> void:
	if i < len(usignals_data):
		usignals_data[i].start_wave()
		for usig_d in usignals_data:
			usig_d.ultrasound_started = true
		wave_started.emit(i)
		

func update_last_wave(i: int, delta: float) -> void:
	if i < len(usignals_data):
		usignals_data[i].update_last_wave(delta)

func stop_wave(i: int) -> void:
	if i < len(usignals_data):
		usignals_data[i].stop_wave()
		wave_stopped.emit(i)

func clear_signals() -> void:
	var inputs : Array[USignalData.InputValue] = []
	for u in usignals_data:
		inputs.append(u.get_input_value())
		u.clear_wave()
	input_set.emit(inputs)

func _on_chest_opened(_cell) -> void:
	add_new_signal()
	new_signal_added.emit()
