@icon("res://icons/controller-icon.svg")
extends Node2D

@onready var tetrisScene = preload("res://scenes/tetris.tscn")
@onready var memoryGameScene = preload("res://scenes/memory_game.tscn")
@onready var sprock_scene = preload("res://scenes/scissors_paper_rock.tscn")

var currentMinigame = null;

func loadMinigame(minigame):
	if currentMinigame == null:
		var game = minigame.instantiate()
		find_parent("Game").find_child("UI").add_child(game)
		currentMinigame = minigame.resource_path

func unLoadMinigame():
	currentMinigame = null;

func _notification(noti):
	if noti == Globals.NOTIFICATION_MINIGAME_CLOSED:
		unLoadMinigame()


## Tetris
func _on_tetris_button_down():
	loadMinigame(tetrisScene)


## Memory game
func _on_memory_game_button_down():
	loadMinigame(memoryGameScene)



func _on_scissors_paper_rock_button_down():
	loadMinigame(sprock_scene)
