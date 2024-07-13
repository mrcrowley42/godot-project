extends Node2D

class_name TotrisManager

# UI NODES
@onready var ui_overlay: CanvasLayer = find_child("UI")
@onready var top_overlay: CanvasLayer = find_child("TopOverlay")
@onready var start_menu: Control = find_child("StartMenu")
@onready var kill_menu: Control = find_child("KillMenu")
@onready var help_menu: Control = find_child("HelpMenu")
@onready var grid_bg: ColorRect = find_child("GridBG")
@onready var score_box: NinePatchRect = find_child("ScoreBox")
@onready var level_box: NinePatchRect = find_child("LevelBox")
@onready var hold_box: NinePatchRect = find_child("HoldBox")
@onready var next_box: NinePatchRect = find_child("NextBox")

@onready var t_logic: TotrisLogic = find_child("TotrisLogic")

# ORIGINAL TEXTS (so they dont get overriden when assigned to)
@onready var og_score_label_start_text = start_menu.find_child("ScoreL").text
@onready var og_level_label_start_text = start_menu.find_child("LevelL").text
@onready var og_score_label_kill_text = kill_menu.find_child("ScoreL").text
@onready var og_level_label_kill_text = kill_menu.find_child("LevelL").text

var best_score = 0
var best_level = 0


func show_start_menu():
	start_menu.show()
	var score_label = start_menu.find_child("ScoreL")
	var level_label = start_menu.find_child("LevelL")
	score_label.text = String(og_score_label_start_text % best_score)
	level_label.text = String(og_level_label_start_text % best_level)

func _ready():
	show_start_menu()
	kill_menu.hide()
	help_menu.hide()

## sawn a particle in the UI (particle kills itself on completion)
func spawn_particle(particle: CPUParticles2D, pos: Vector2, colour: Color, lifetime=null):
	var part: CPUParticles2D = particle.duplicate()
	top_overlay.add_child(part)
	part.connect("finished", t_logic.remove_node.bind(part))
	
	if lifetime != null:
		part.lifetime = max(0.05, lifetime)
	part.modulate = colour / 255
	part.modulate.a = 1  # reset the alpha
	part.position = pos
	part.emitting = true

## call this so it doesnt have to update every single frame in _process()
func update_score():
	score_box.find_child("Label").text = str(t_logic.score)
	level_box.find_child("Label").text = str(t_logic.level)

func on_game_over():
	kill_menu.show()
	var score_label = kill_menu.find_child("ScoreL")
	var level_label = kill_menu.find_child("LevelL")
	score_label.text = String(og_score_label_kill_text % t_logic.score)
	level_label.text = String(og_level_label_kill_text % t_logic.level)
	
	var high_score: bool = t_logic.score > best_score
	var high_level: bool = t_logic.level > best_level
	best_score = t_logic.score if high_score else best_score
	best_level = t_logic.level if high_level else best_level
	kill_menu.find_child("BestScore").visible = high_score
	kill_menu.find_child("BestLevel").visible = high_level

## data is the same thats returned from get_save_data()
func load_save_data(data):
	best_score = data["best_score"]
	best_level = data["best_level"]

func get_save_data():
	return {"best_score": best_score, "best_level": best_level}

func _on_play_button_down():
	start_menu.hide()
	kill_menu.hide()
	t_logic.reset_game()
	t_logic.start()

func _on_help_btn_button_down():
	help_menu.visible = !help_menu.visible
	if t_logic.running:
		t_logic.paused = help_menu.visible

func _on_close_btn_button_down():
	if help_menu.visible:  # close help menu if its open
		_on_help_btn_button_down()
		return
	# close totris
	get_tree().root.propagate_notification(Globals.NOTIFICATION_TOTRIS_CLOSED)
	queue_free()  # maybe dont delete? idk it'll do for now

func _on_menu_button_down():
	kill_menu.hide()
	show_start_menu()
