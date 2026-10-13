extends Control

const WIDTH := 200

@export var usignal_scene: PackedScene

@onready var u_signal_control = $USignalControl

var ultrasound_data: UltrasoundData

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
			ultrasound_data.start_wave(i)
		elif Input.is_action_pressed(action_name):
			ultrasound_data.update_last_wave(i, delta)
		elif Input.is_action_just_released(action_name):
			ultrasound_data.stop_wave(i)
