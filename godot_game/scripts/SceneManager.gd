extends Node2D

@onready var tetrisScene = preload("res://scenes/tetris.tscn")
@onready var memoryGameScene = preload("res://scenes/memory_game.tscn")

var currentMinigame = null;

func loadMinigame(minigame):
	if currentMinigame == null:
		var game = minigame.instantiate()
		find_parent("Game").find_child("UI").add_child(game)
		currentMinigame = minigame.resource_name

# todo: call this somewhere
func unLoadMinigame():
	currentMinigame = null;


## Tetris
func _on_tetris_btn_button_down():
	loadMinigame(tetrisScene)


## Memory game
func _on_memory_game_btn_button_down():
	loadMinigame(memoryGameScene)
