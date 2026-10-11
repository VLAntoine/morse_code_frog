class_name PlayerData
extends Node

signal position_changed

var cell_position:= Vector2(1,1):
	set(value):
		if cell_position != value:
			cell_position = value
			position_changed.emit()
	
func move_up() -> void:
	cell_position.y -= 1

func move_down() -> void:
	cell_position += Vector2(0,1)

func move_left() -> void:
	cell_position += Vector2(-1,0)

func move_right() -> void:
	cell_position += Vector2(1,0)
