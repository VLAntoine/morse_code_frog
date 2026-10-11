extends Node

func enter_game_phase():
	get_tree().change_scene_to_file("res://scenes/views/game_view.tscn")
