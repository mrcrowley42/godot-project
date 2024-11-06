@icon("res://icons/class-icons/controller-icon.svg")
class_name MinigameManager extends Node2D

# Preload all the minigames.
@onready var totris_scene = preload ("res://scenes/MiniGames/totris.tscn")
@onready var memory_game_scene = preload ("res://scenes/MiniGames/memory_game.tscn")
@onready var sprock_scene = preload ("res://scenes/MiniGames/scissors_paper_rock.tscn")
@onready var zen_mode_scene = preload ("res://scenes/MiniGames/zen_mode.tscn")

@onready var clippy_area = %ClippyArea
@onready var act_menu = %ActivityMenu
@onready var status_manager = %StatusManager

var save_data: Dictionary = {}
var current_minigame = null;
var current_time_scale: float
var totris_scene_instance: TotrisManager = null
var memory_match_instance: MemoryGameManager = null

## Loads the minigame matching the [param minigame] variable, and places it just
## below options menu, but above all other elements.
func load_minigame(pre_loaded=null, instance=null, do_transition=false) -> void:
	assert(pre_loaded != null or instance != null)  # either one or the other
	if current_minigame == null:
		%BtnClick.play()
		
		if do_transition:
			await Globals.perform_closing_transition(owner.trans_img, owner.ui_overlay.position)
			Globals.perform_opening_transition(owner.trans_img, owner.ui_overlay.position)
		
		var game = pre_loaded.instantiate() if pre_loaded != null else instance
		current_time_scale = status_manager.time_multiplier
		status_manager.time_multiplier = 0
		act_menu.hide()
		find_parent("Game").find_child("UI").add_child(game)
		find_parent("Game").find_child("UI").move_child(game, 0)
		current_minigame = pre_loaded.resource_path if pre_loaded != null else game.name
		%ActButton.disabled = true
		%FoodButton.disabled = true


## Tell game that a minigame is no longer open.
func unload_minigame(do_transition=false, game_instance=null) -> void:
	%BtnClick.play()
	
	if do_transition:
		assert(game_instance != null)
		await Globals.perform_closing_transition(owner.trans_img, owner.ui_overlay.position)
		Globals.perform_opening_transition(owner.trans_img, owner.ui_overlay.position)
		game_instance.queue_free()
	
	current_minigame = null;
	status_manager.time_multiplier = current_time_scale
	%ActButton.disabled = false
	%FoodButton.disabled = false


## Trigger unloading function when a minigame scene is freed.
func _notification(noti) -> void:
	if noti == Globals.NOTIFICATION_MINIGAME_CLOSED:
		unload_minigame()
	if noti == Globals.NOTIFICATION_TOTRIS_CLOSE:
		save_totris_data()
		unload_minigame(true, totris_scene_instance)
	if noti == Globals.NOTIFICATION_MEMORY_MATCH_CLOSE:
		unload_minigame(true, memory_match_instance)


## called when the game is about to close and data hasn't been saved to file yet
func finalise_save_data() -> void:
	if current_minigame != null:
		if current_minigame == "Totris":
			save_totris_data()
		unload_minigame()


## get totris save data before its unloaded
func save_totris_data() -> void:
	save_data["totris"] = totris_scene_instance.get_save_data()  # set or override


## Loads Totris scene.
func _on_totris_button_down() -> void:
	if totris_scene_instance == null:
		totris_scene_instance = totris_scene.instantiate()
		if save_data.has("totris"):
			totris_scene_instance.load_save_data(save_data["totris"])  # load data on creation
	load_minigame(null, totris_scene_instance, true)


## Loads Memory scene.
func _on_memory_game_button_down() -> void:
	if memory_match_instance == null:
		memory_match_instance = memory_game_scene.instantiate()
	load_minigame(null, memory_match_instance, true)


## Loads scissors-paper-rock scene.
func _on_scissors_paper_rock_button_down() -> void:
	load_minigame(sprock_scene, null)


## Loads Relaxation scene.
func _on_zen_mode_button_down() -> void:
	load_minigame(zen_mode_scene, null)


## save data
func save() -> Dictionary:
	return save_data


func load(data) -> void:
	save_data = data


func _on_tree_exiting() -> void:
	# Ensure that before changing scene, if clippy mode is active it is toggled off.
	if clippy_area.clippy:
		clippy_area.toggle_clippy_mode()
