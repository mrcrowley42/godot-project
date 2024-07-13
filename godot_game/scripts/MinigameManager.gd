@icon("res://icons/controller-icon.svg")
class_name MinigameManager extends Node2D

@onready var act_menu = %ActivityControls

# Preload all the minigames.
@onready var totris_scene = preload ("res://scenes/MiniGames/totris.tscn")
var totris_scene_instance: TotrisManager = null
@onready var memory_game_scene = preload ("res://scenes/MiniGames/memory_game.tscn")
@onready var sprock_scene = preload ("res://scenes/MiniGames/scissors_paper_rock.tscn")
@onready var zen_mode_scene = preload ("res://scenes/MiniGames/zen_mode.tscn")

var save_data = {}
var current_minigame = null;
var current_time_scale: float

## Loads the minigame matching the [param minigame] variable, and places it just
## below options menu, but above all other elements.
func load_minigame(pre_loaded=null, instance=null):
	assert(pre_loaded != null or instance != null)  # either one or the other
	if current_minigame == null:
		%BtnClick.play()
		current_time_scale = %StatusManager.time_multiplier
		%StatusManager.time_multiplier = 0
		act_menu.hide()
		var game = pre_loaded.instantiate() if pre_loaded != null else instance
		find_parent("Game").find_child("UI").add_child(game)
		find_parent("Game").find_child("UI").move_child(game, 0)
		current_minigame = game.resource_path if pre_loaded != null else game.name
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
	if noti == Globals.NOTIFICATION_TOTRIS_CLOSED:
		save_totris_data()
		unload_minigame()

## called when the game is about to close and data hasn't been saved to file yet
func finalise_save_data():
	if current_minigame != null:
		if current_minigame == totris_scene_instance.name:
			save_totris_data()
		unload_minigame()

## get totris save data before its unloaded
func save_totris_data():
	save_data["totris"] = totris_scene_instance.get_save_data()  # set or override

## Loads Totris scene.
func _on_totris_button_down():
	if totris_scene_instance == null:
		totris_scene_instance = totris_scene.instantiate()
		if "totris" in save_data:
			totris_scene_instance.load_save_data(save_data["totris"])  # load data on creation
	load_minigame(null, totris_scene_instance)

## Loads Memory scene.
func _on_memory_game_button_down():
	load_minigame(memory_game_scene)

## Loads scissors-paper-rock scene.
func _on_scissors_paper_rock_button_down():
	load_minigame(sprock_scene)

## Loads Relaxation scene.
func _on_zen_mode_button_down():
	load_minigame(zen_mode_scene)


## save data
func save():
	return save_data

func load(data):
	save_data = data
