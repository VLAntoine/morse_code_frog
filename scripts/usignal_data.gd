class_name USignalData

signal wave_started
signal last_wave_changed
signal wave_stopped
signal waves_cleared

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

const DASH_DURATION := 0.2

var waves: Array[float] = []
var ultrasound_started := false
var running := false

func start_wave() -> void:
	waves.append(0.0)
	ultrasound_started = true
	running = true
	wave_started.emit()

func update_last_wave(delta: float) -> void:
	if len(waves) > 0:
		waves[-1] += delta
		last_wave_changed.emit()

func stop_wave() -> void:
	running = false
	wave_stopped.emit()

func get_morse_sequence() -> Array[MorseValue]:
	var morse_sequence: Array[MorseValue] = []
	for w in waves:
		if w > DASH_DURATION:
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

func clear_wave() -> void:
	waves.clear()
	ultrasound_started = false
	waves_cleared.emit()
 
