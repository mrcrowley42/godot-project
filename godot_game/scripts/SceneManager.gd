extends Node2D

@onready var tetrisScene = "res://scenes/tetris.tscn"


## Tetris button in ActivityContatiner
func _on_button_2_button_down():
	get_tree().change_scene_to_file(tetrisScene)
