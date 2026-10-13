extends Control

@export var usignal_scene: PackedScene

const OFF_DURATION := 0.15

@onready var u_signal_control = $USignalControl
@onready var off_timer = $OffTimer

var ultrasound_data: UltrasoundData

func _ready() -> void:
	off_timer.wait_time = OFF_DURATION
	off_timer.one_shot = true
	off_timer.autostart = false

func setup(us_data: UltrasoundData) -> void:
	ultrasound_data = us_data
	
	for usignal_data in ultrasound_data.usignals_data:
		var us_node = usignal_scene.instantiate()
		u_signal_control.add_child(us_node)
		us_node.setup(usignal_data)

func _process(delta: float) -> void:
	for i in u_signal_control.get_child_count():
		var action_name := "start_wave_%s" % [str(i + 1)]
		if Input.is_action_just_pressed(action_name):
			off_timer.stop()
			ultrasound_data.start_wave(i)
		elif Input.is_action_pressed(action_name):
			ultrasound_data.update_last_wave(i, delta)
		elif Input.is_action_just_released(action_name):
			ultrasound_data.stop_wave(i)
			start_off_timer()

func start_off_timer() -> void:
	var is_started := true
	for usig_d in ultrasound_data.usignals_data:
		if usig_d.running:
			is_started = false
	if is_started:
		off_timer.start()

func _on_off_timer_timeout() -> void:
	ultrasound_data.clear_signals()
