@icon("res://icons/controller-icon.svg")
extends Node2D

@onready var act_menu = %ActivityControls

@onready var tetrisScene = preload("res://scenes/tetris.tscn")
@onready var memoryGameScene = preload("res://scenes/memory_game.tscn")
@onready var sprock_scene = preload("res://scenes/scissors_paper_rock.tscn")

var currentMinigame = null;
var current_time_scale
func loadMinigame(minigame):
	if currentMinigame == null:
		current_time_scale = %StatusManager.time_multiplier
		%StatusManager.time_multiplier = 0
		act_menu.hide()
		var game = minigame.instantiate()
		find_parent("Game").find_child("UI").add_child(game)
		currentMinigame = minigame.resource_path

func unLoadMinigame():
	currentMinigame = null;
	%StatusManager.time_multiplier = current_time_scale

func _notification(noti):
	if noti == Globals.NOTIFICATION_MINIGAME_CLOSED:
		unLoadMinigame()


## Tetris
func _on_tetris_button_down():
	loadMinigame(tetrisScene)

## Memory game
func _on_memory_game_button_down():
	loadMinigame(memoryGameScene)

## Scissors paper rock
func _on_scissors_paper_rock_button_down():
	loadMinigame(sprock_scene)
