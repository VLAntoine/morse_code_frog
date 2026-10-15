class_name USignalNode
extends Control

signal end_oscilloscope_reached

const ON_HEIGHT := 8
const OFF_HEIGHT := 1
const DOT_SPEED := 50.0
const DOT_INIT_POSITION := 4
const MAX_WIDTH := 149

var usignal_data: USignalData

var dot_panel: Panel
var panels: Array[Panel] = []

var ultrasound_style: StyleBoxFlat = load("res://assets/styles/ultrasound_style.tres")
var ultrasound_gradient: Gradient = load("res://assets/styles/ultrasound_gradient.tres")

func _ready() -> void:
	dot_panel = Panel.new()
	add_child(dot_panel)
	dot_panel.add_theme_stylebox_override("panel", ultrasound_style)
	dot_panel.self_modulate = Color.BLACK
	dot_panel.size = Vector2(OFF_HEIGHT,OFF_HEIGHT)
	dot_panel.position = Vector2(DOT_INIT_POSITION,10)

func setup(us_data: USignalData) -> void:
	usignal_data = us_data
	usignal_data.wave_started.connect(_on_wave_started)
	usignal_data.last_wave_changed.connect(_on_last_wave_changed)
	usignal_data.waves_cleared.connect(_on_waves_cleared)

func _process(delta: float) -> void:
	if usignal_data.ultrasound_started:
		dot_panel.position.x += delta * DOT_SPEED
		if dot_panel.position.x >= DOT_INIT_POSITION + MAX_WIDTH:
			end_oscilloscope_reached.emit()

func _on_wave_started() -> void:
	
	var panel := Panel.new()
	add_child(panel)
	panel.add_theme_stylebox_override("panel", ultrasound_style)
	panel.self_modulate = ultrasound_gradient.sample(0.0)
	panel.position.x = dot_panel.position.x
	panel.position.y = 6
	panel.size.y = ON_HEIGHT
	panel.size.x = 0
	panels.append(panel)

func _on_last_wave_changed() -> void:
	var last_wave: float = usignal_data.waves[-1]
	panels[-1].size.x = (last_wave) * DOT_SPEED + 2*OFF_HEIGHT
	panels[-1].self_modulate = ultrasound_gradient.sample(last_wave/usignal_data.DASH_DURATION)

func _on_waves_cleared() -> void:
	for p in panels:
		p.queue_free()
	panels.clear()
	dot_panel.position.x = DOT_INIT_POSITION
	
