extends Node2D

@onready var start_button = $StartButton
@onready var start_audio = $StartButtonAudioStreamPlayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start_wave_1"):
		_on_start_button_pressed()

func _on_start_button_pressed() -> void:
	start_audio.play()
	var tween = create_tween()
	tween.tween_interval(0.5)
	await tween.finished
	SceneManager.enter_game_phase()
