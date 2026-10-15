extends Control

const TWEEN_DURATION:= 0.05

var left_hand_passive_pos:= Vector2(-44.0,45.0)
var left_hand_active_pos:= Vector2(-56,28)
var right_hand_passive_pos:= Vector2(46,45)
var right_hand_active_pos:= Vector2(56,28)

@onready var controller_control = $ControllerTextureRect
@onready var button_red_control = $ButtonRedTextureRect
@onready var button_green_control = $ButtonGreenTextureRect
@onready var right_hand_control = $RightHandTextureRect
@onready var left_hand_control = $LeftHandTextureRect

var button_red_pressed_texture = preload("res://assets/images/controller/button_red_pressed.png")
var button_red_unpressed_texture = preload("res://assets/images/controller/button_red_unpressed.png")
var button_green_pressed_texture = preload("res://assets/images/controller/button_green_pressed.png")
var button_green_unpressed_texture = preload("res://assets/images/controller/button_green_unpressed.png")

var ultrasound_data: UltrasoundData

func _ready() -> void:
	right_hand_control.visible = false
	button_green_control.visible = false
	GameManager.chest_opened.connect(_on_chest_opened)

func setup(us_data: UltrasoundData):
	ultrasound_data = us_data
	ultrasound_data.wave_started.connect(_on_wave_started)
	ultrasound_data.wave_stopped.connect(_on_wave_stopped)

func get_hand_and_button(i: int) -> Dictionary:
	match i:
		0:
			return {
				"hand": left_hand_control,
				"button": button_red_control,
				"button_texture_unpressed": button_red_unpressed_texture,
				"button_texture_pressed": button_red_pressed_texture,
				"passive_pos": left_hand_passive_pos,
				"active_pos": left_hand_active_pos
			}
		1:
			return {
				"hand": right_hand_control,
				"button": button_green_control,
				"button_texture_unpressed": button_green_unpressed_texture,
				"button_texture_pressed": button_green_pressed_texture,
				"passive_pos": right_hand_passive_pos,
				"active_pos": right_hand_active_pos
			}
	return {}

func _on_wave_started(i: int) -> void:
	var h_n_b_dict = get_hand_and_button(i)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(h_n_b_dict["hand"],"position",h_n_b_dict["active_pos"], TWEEN_DURATION)
	await tween.finished
	h_n_b_dict["button"].texture = h_n_b_dict["button_texture_pressed"]

func _on_wave_stopped(i:int) -> void:
	var h_n_b_dict = get_hand_and_button(i)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(h_n_b_dict["hand"],"position",h_n_b_dict["passive_pos"], TWEEN_DURATION)
	await tween.finished
	h_n_b_dict["button"].texture = h_n_b_dict["button_texture_unpressed"]

func _on_chest_opened(_cell) -> void:
	right_hand_control.visible = true
	button_green_control.visible = true
