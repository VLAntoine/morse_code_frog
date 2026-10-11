extends Control

const WIDTH := 200
const ON_HEIGHT := 16
const OFF_HEIGHT := 2
const DOT_SPEED := 50.0


var ultrasound_data: UltrasoundData

@onready var off_timer = $OffTimer

var panels: Array[Panel] = []
var dot_panel: Panel

func _ready() -> void:
	dot_panel = Panel.new()
	add_child(dot_panel)
	dot_panel.size = Vector2(OFF_HEIGHT,OFF_HEIGHT)
	dot_panel.position = Vector2(0,7)

func setup(us_data: UltrasoundData) -> void:
	ultrasound_data = us_data
	ultrasound_data.ultrasound_started.connect(_on_ultrasound_started)
	ultrasound_data.last_wave_length_changed.connect(_on_last_wave_length_changed)
	ultrasound_data.wave_length_cleared.connect(_on_wave_length_cleared)
	
	off_timer.wait_time = ultrasound_data.OFF_DURATION
	off_timer.timeout.connect(_on_off_timer_timeout)	

func _process(delta: float) -> void:
	if ultrasound_data && !ultrasound_data.is_new_ultrasound():
		dot_panel.position.x += delta * DOT_SPEED
	
	if Input.is_action_just_pressed("start_ultrasound_1"):
		off_timer.stop()
		ultrasound_data.start_wave()
	elif Input.is_action_pressed("start_ultrasound_1"):
		ultrasound_data.update_last_wave(delta)
	elif Input.is_action_just_released("start_ultrasound_1"):
		off_timer.start()
		ultrasound_data.stop_wave()

func _on_ultrasound_started() -> void:
	var panel := Panel.new()
	add_child(panel)
	panel.position.x = dot_panel.position.x
	panel.size.y = ON_HEIGHT
	panel.size.x = 0
	panels.append(panel)

func _on_last_wave_length_changed() -> void:
	panels[-1].size.x = (ultrasound_data.waves_len_1[-1]) * DOT_SPEED + OFF_HEIGHT

func _on_wave_length_cleared() -> void:
	for p in panels:
		p.queue_free()
	panels.clear()

func _on_off_timer_timeout() -> void:
	dot_panel.position.x = 0
	ultrasound_data.end_waves()
