@icon("res://icons/controller-icon.svg")
extends Node2D

@onready var act_menu = %ActivityControls
@onready var tetrisScene = preload("res://scenes/MiniGames/tetris.tscn")
@onready var memoryGameScene = preload("res://scenes/MiniGames/memory_game.tscn")
@onready var sprock_scene = preload("res://scenes/MiniGames/scissors_paper_rock.tscn")
@onready var zen_mode_scene = preload("res://scenes/MiniGames/zen_mode.tscn")

var current_minigame = null;
var current_time_scale: float

## Loads the minigame matching the [param minigame] variable, and places it just
## below options menu, but above all other elements.
func load_minigame(minigame):
	if current_minigame == null:
		%BtnClick.play()
		current_time_scale = %StatusManager.time_multiplier
		%StatusManager.time_multiplier = 0
		act_menu.hide()
		var game = minigame.instantiate()
		find_parent("Game").find_child("UI").add_child(game)
		find_parent("Game").find_child("UI").move_child(game, 0)
		current_minigame = minigame.resource_path
		%ActButton.disabled = true
		%FoodButton.disabled = true

## Tell game that a minigame is no longer open.
func unload_minigame():
	%BtnClick.play()
	current_minigame = null;
	%StatusManager.time_multiplier = current_time_scale
	%ActButton.disabled = false
	%FoodButton.disabled = false
	
## Trigger unloading function when a minigame scene is freed.
func _notification(noti):
	if noti == Globals.NOTIFICATION_MINIGAME_CLOSED:
		unload_minigame()

## Loads Tetris scene.
func _on_tetris_button_down():
	load_minigame(tetrisScene)

## Loads Memory scene.
func _on_memory_game_button_down():
	load_minigame(memoryGameScene)

## Loads scissors-paper-rock scene.
func _on_scissors_paper_rock_button_down():
	load_minigame(sprock_scene)

## Loads Relaxation scene.
func _on_zen_mode_button_down():
	load_minigame(zen_mode_scene)
