class_name MemoryGame extends Node2D

# UI NODES
@onready var ui_overlay: CanvasLayer = find_child("UI")
@onready var top_overlay: CanvasLayer = find_child("TopOverlay")
@onready var start_menu: Control = find_child("StartMenu")
@onready var finish_menu: Control = find_child("FinishMenu")
@onready var help_menu: Control = find_child("HelpMenu")
@onready var card_grid: GridContainer = find_child("CardGrid")
@onready var final_score: Label = find_child("FinalScore")
@onready var final_icon: Button = find_child("FinalIcon")
@onready var new_best: RichTextLabel = find_child("NewBest")
@onready var best_time_label: Label = find_child("bestTime")
@onready var best_guesses_label: Label = find_child("bestGuesses")

@onready var m_logic: MemoryGameLogic = find_child("MemoryGameLogic")

# OG TEXTS
@onready var og_time_label_start_text = best_time_label.text
@onready var og_guesses_label_start_text = best_guesses_label.text

@export var ui_overlay_sprite: Sprite2D
@export var score_ui_sprite: NinePatchRect
@export var help_bg_sprite: NinePatchRect

const FINAL_SCORE_LABEL_TEXT = {
	null: "-\n-",
	true: "Time:\n%.2f seconds",
	false: "Guesses:\n%.0f"
}

var FINAL_ICON = {
	true: load("res://icons/stopwatch.svg"),
	false: load("res://icons/question-square.svg"),
}

var best_time = null
var lowest_guesses = null


func _ready() -> void:
	var ui_theme = find_parent("Game").find_child("UI_Theme_Manager").current_theme
	show_start_menu()
	ui_overlay_sprite.texture = ui_theme.memory_ui
	score_ui_sprite.texture = ui_theme.box_inverted
	help_bg_sprite.texture = ui_theme.box
	help_menu.hide()
	finish_menu.hide()


func show_start_menu():
	start_menu.show()
	var time_label = start_menu.find_child("bestTime")
	var guesses_label = start_menu.find_child("bestGuesses")
	time_label.text = String(og_time_label_start_text % best_time)
	guesses_label.text = String(og_guesses_label_start_text % lowest_guesses)
	
	var time = str(floor(best_time * 100) / 100) if best_time != null else "-"
	var guess = str(lowest_guesses) if lowest_guesses != null else "-"
	best_time_label.text = og_time_label_start_text % time
	best_guesses_label.text = og_guesses_label_start_text % guess


func show_finish_menu(is_timed: bool, score: float):
	finish_menu.show()
	final_score.text = FINAL_SCORE_LABEL_TEXT[is_timed] % score
	final_icon.icon = FINAL_ICON[is_timed]
	card_grid.modulate.a = .5
	
	var new_best_time = is_timed && (best_time == null || score < best_time)
	var new_lowest_guess = !is_timed && (lowest_guesses == null || score < lowest_guesses)
	new_best.visible = new_best_time || new_lowest_guess
	
	if new_best_time:
		best_time = float(score)
	if new_lowest_guess:
		lowest_guesses = int(score)


## data is the same thats returned from get_save_data()
func load_save_data(data):
	best_time = data["best_time"]
	lowest_guesses = data["lowest_guesses"]


func get_save_data():
	return {"best_time": best_time, "lowest_guesses": lowest_guesses}


func _on_timed_start_btn_button_down() -> void:
	start_menu.hide()
	m_logic.start_timed_game()
	card_grid.modulate.a = 1.


func _on_normal_start_btn_button_down() -> void:
	start_menu.hide()
	m_logic.start_normal_game()
	card_grid.modulate.a = 1.


func _on_help_btn_button_down() -> void:
	%SFX.play_sound("click")
	help_menu.visible = !help_menu.visible


func _on_close_btn_button_down():
	if help_menu.visible:  # close help menu if its open
		_on_help_btn_button_down()
		return
	get_tree().root.propagate_notification(Globals.NOTIFICATION_MEMORY_MATCH_CLOSE)


func _on_retry_button_down() -> void:
	finish_menu.hide()
	@warning_ignore("standalone_ternary")
	_on_timed_start_btn_button_down() if m_logic.is_timed_game else _on_normal_start_btn_button_down()


func _on_menu_button_down() -> void:
	finish_menu.hide()
	show_start_menu()
