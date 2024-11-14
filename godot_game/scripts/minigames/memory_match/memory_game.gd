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

@onready var m_logic: MemoryGameLogic = find_child("MemoryGameLogic")

# OG TEXTS
@onready var og_time_label_start_text = start_menu.find_child("bestTime").text
@onready var og_guesses_label_start_text = start_menu.find_child("bestGuesses").text

const FINAL_SCORE_LABEL_TEXT = {
	null: "-\n-",
	true: "Time:\n%.2f seconds",
	false: "Guesses:\n%.0f"
}

var FINAL_ICON = {
	true: load("res://icons/stopwatch.svg"),
	false: load("res://icons/question-square.svg"),
}

var best_time = 0
var lowest_guesses = 0


func _ready() -> void:
	show_start_menu()
	help_menu.hide()
	finish_menu.hide()

func show_start_menu():
	start_menu.show()
	var time_label = start_menu.find_child("bestTime")
	var guesses_label = start_menu.find_child("bestGuesses")
	time_label.text = String(og_time_label_start_text % best_time)
	guesses_label.text = String(og_guesses_label_start_text % lowest_guesses)

func show_finish_menu(is_timed: bool, score: float):
	finish_menu.show()
	final_score.text = FINAL_SCORE_LABEL_TEXT[is_timed] % score
	final_icon.icon = FINAL_ICON[is_timed]

func _on_timed_start_btn_button_down() -> void:
	start_menu.hide()
	m_logic.start_timed_game()

func _on_normal_start_btn_button_down() -> void:
	start_menu.hide()
	m_logic.start_normal_game()

func _on_help_btn_button_down() -> void:
	%SFX.play_sound("click")
	help_menu.visible = !help_menu.visible

func _on_close_btn_button_down():
	if help_menu.visible:  # close help menu if its open
		_on_help_btn_button_down()
		return
	get_tree().root.propagate_notification(Globals.NOTIFICATION_MEMORY_MATCH_CLOSE)
