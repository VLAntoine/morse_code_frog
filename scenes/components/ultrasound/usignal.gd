class_name USignalNode
extends Control

const ON_HEIGHT := 16
const OFF_HEIGHT := 2
const DOT_SPEED := 50.0

var usignal_data: USignalData

var dot_panel: Panel
var panels: Array[Panel] = []

@onready var off_timer = $OffTimer

var ultrasound_style: StyleBoxFlat = load("res://assets/styles/ultrasound_style.tres")
var ultrasound_gradient: Gradient = load("res://assets/styles/ultrasound_gradient.tres")

func _ready() -> void:
	dot_panel = Panel.new()
	add_child(dot_panel)
	dot_panel.add_theme_stylebox_override("panel", ultrasound_style)
	dot_panel.self_modulate = Color.BLACK
	dot_panel.size = Vector2(OFF_HEIGHT,OFF_HEIGHT)
	dot_panel.position = Vector2(0,7)

func setup(us_data: USignalData) -> void:
	usignal_data = us_data
	usignal_data.wave_started.connect(_on_wave_started)
	usignal_data.last_wave_changed.connect(_on_last_wave_changed)
	usignal_data.wave_stopped.connect(_on_wave_stopped)
	usignal_data.waves_cleared.connect(_on_waves_cleared)
	
	off_timer.wait_time = usignal_data.OFF_DURATION
	off_timer.timeout.connect(_on_off_timer_timeout)

func _process(delta: float) -> void:
	if usignal_data.ultrasound_started:
		dot_panel.position.x += delta * DOT_SPEED

func _on_wave_started() -> void:
	off_timer.stop()
	
	var panel := Panel.new()
	add_child(panel)
	panel.add_theme_stylebox_override("panel", ultrasound_style)
	panel.self_modulate = ultrasound_gradient.sample(0.0)
	panel.position.x = dot_panel.position.x
	panel.size.y = ON_HEIGHT
	panel.size.x = 0
	panels.append(panel)

func _on_last_wave_changed() -> void:
	var last_wave: float = usignal_data.waves[-1]
	panels[-1].size.x = (last_wave) * DOT_SPEED + OFF_HEIGHT
	panels[-1].self_modulate = ultrasound_gradient.sample(last_wave/usignal_data.DASH_DURATION)

func _on_wave_stopped() -> void:
	off_timer.start()

func _on_waves_cleared() -> void:
	for p in panels:
		p.queue_free()
	panels.clear()
	dot_panel.position.x = 0
	
func _on_off_timer_timeout() -> void:
	usignal_data.timeout = true
