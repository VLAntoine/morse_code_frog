class_name UltrasoundData
extends Node

signal input_set
signal ultrasound_started
signal last_wave_length_changed
signal wave_length_cleared

enum MorseValue {
	DOT,
	DASH
}

enum InputValue{
	UP,
	DOWN,
	RIGHT,
	LEFT,
	ERROR
}

const DASH_DURATION := 0.15
const OFF_DURATION := 0.15

var progress := 0.0

var action_pressed := false

var waves_len_1: Array[float] = []

func is_new_ultrasound() -> bool:
	return len(waves_len_1) == 0

func start_wave() -> void:
	waves_len_1.append(0.0)
	action_pressed = true
	ultrasound_started.emit()

func update_last_wave(delta: float) -> void:
	if len(waves_len_1) > 0:
		waves_len_1[-1] += delta
		last_wave_length_changed.emit()

func stop_wave() -> void:
	action_pressed = false

func get_morse_sequence() -> Array[MorseValue]:
	var morse_sequence: Array[MorseValue] = []
	for wave in waves_len_1:
		if wave > DASH_DURATION:
			morse_sequence.append(MorseValue.DASH)
		else:
			morse_sequence.append(MorseValue.DOT)
	return morse_sequence

func get_input_value() -> InputValue :
	var morse_sequence := get_morse_sequence()
	if len(morse_sequence) != 2:
		return InputValue.ERROR
	else:
		if morse_sequence[0] == MorseValue.DOT && morse_sequence[1] == MorseValue.DOT:
			return InputValue.UP
		elif morse_sequence[0] == MorseValue.DOT && morse_sequence[1] == MorseValue.DASH:
			return InputValue.RIGHT
		elif morse_sequence[0] == MorseValue.DASH && morse_sequence[1] == MorseValue.DOT:
			return InputValue.LEFT
		elif morse_sequence[0] == MorseValue.DASH && morse_sequence[1] == MorseValue.DASH:
			return InputValue.DOWN
	return InputValue.ERROR

func end_waves() -> void:
	if !action_pressed:
		input_set.emit(get_input_value())
	waves_len_1.clear()
	wave_length_cleared.emit()
