extends Control

const WIDTH := 200
const ON_HEIGHT := 16
const OFF_HEIGHT := 2

var ultrasound_data: UltrasoundData

@onready var duration_timer = $DurationTimer

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
	
	duration_timer.autostart = true
	duration_timer.one_shot = false
	duration_timer.wait_time = ultrasound_data.DURATION
	duration_timer.timeout.connect(_on_duration_timer_timeout)

func get_spent_time_ratio() -> float:
	return (ultrasound_data.DURATION - duration_timer.time_left) / ultrasound_data.DURATION	

func _process(delta: float) -> void:
	dot_panel.position.x = get_spent_time_ratio() * WIDTH
	if Input.is_action_just_pressed("start_ultrasound_1"):
		ultrasound_data.start_wave()
	elif Input.is_action_pressed("start_ultrasound_1"):
		ultrasound_data.update_last_wave(delta)
	elif Input.is_action_just_released("start_ultrasound_1"):
		ultrasound_data.stop_wave()

func _on_ultrasound_started() -> void:
	var panel := Panel.new()
	add_child(panel)
	panel.position.x = get_spent_time_ratio() * WIDTH
	panel.size.y = ON_HEIGHT
	panel.size.x = 0
	panels.append(panel)

func _on_last_wave_length_changed() -> void:
	panels[-1].size.x = ultrasound_data.waves_len_1[-1] / ultrasound_data.DURATION * WIDTH + OFF_HEIGHT

func _on_wave_length_cleared() -> void:
	for p in panels:
		p.queue_free()
	panels.clear()

func _on_duration_timer_timeout() -> void:
	ultrasound_data.end_waves()
