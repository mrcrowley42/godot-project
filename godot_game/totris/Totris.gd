extends Node2D

class_name TotrisManager

# UI NODES
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


func _ready():
	start_menu.show()
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
	get_tree().root.propagate_notification(Globals.NOTIFICATION_MINIGAME_CLOSED)
	queue_free()

func _on_menu_button_down():
	kill_menu.hide()
	start_menu.show()
