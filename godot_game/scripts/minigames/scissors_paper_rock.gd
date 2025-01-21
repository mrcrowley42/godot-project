extends MiniGameLogic
@onready var og_text = %ScoreLabel.text
@export var box_sprite: Sprite2D
@export var help_menu: Node
@export var creature_choice_sprite: Sprite2D
@export var creature_prev: AnimatedSprite2D
var creature_score: int = 0
var player_score: int = 0
var choices = ['rock', 'paper', 'scissors']
@onready var closed = load("res://images/scissors-paper-rock/box_closed.png")
@onready var opened = load("res://images/scissors-paper-rock/box_opened.png")

@export var ui_overlay_sprite: Sprite2D
@export var score_ui_sprite: NinePatchRect

var choice_2_sprite = {
	'rock': load("res://images/scissors-paper-rock/rock.png"),
	'scissors': load("res://images/scissors-paper-rock/scissors.png"),
	'paper': load("res://images/scissors-paper-rock/paper.png")}

var queued = false
func _process(_delta):
	%ScoreLabel.text = og_text % [player_score, creature_score]

func _ready() -> void:
	creature_prev.gen_preview()
	var ui_theme = find_parent("Game").find_child("UI_Theme_Manager").current_theme
	ui_overlay_sprite.texture = ui_theme.memory_ui
	score_ui_sprite.texture = ui_theme.box_inverted
	%CreatureChoice.text = ""
	#creature_choice_sprite.texture = null

func win():
	player_score += 1
	%GameStatus.text = 'Victory\nYou win'
	%SFX.play_sound("correct")
	creature_prev.animation = "angry"
	
func lose():
	creature_score += 1
	%GameStatus.text = 'Defeat\nCreature wins'
	creature_prev.animation = "joy" if creature_prev.sprite_frames.has_animation("joy") else "chill"
	%SFX.play_sound("wrong")

func enable():
	queued = false

func play(user_choice):
	if queued:
		return
	queued = true
	reset_scene()
	await get_tree().create_timer(1).timeout
	var creature_choice = choices.pick_random()
	creature_choice_sprite.texture = choice_2_sprite[creature_choice]
	
	var anim_player: AnimationPlayer = creature_choice_sprite.find_child('Player')
	anim_player.play("reveal")
	await get_tree().create_timer(.125).timeout
	%CreatureChoice.text = str('Creature chose ' + creature_choice)
	if creature_choice == user_choice:
		%GameStatus.text = 'Draw\nNeither wins'
		creature_prev.animation = "idle"
		%SFX.play_sound("draw")
	elif user_choice == 'rock' and creature_choice == 'scissors':
		win()

	elif user_choice == 'paper' and creature_choice == 'rock':
		win()

	elif user_choice == 'scissors' and creature_choice == 'paper':
		win()
		
	else: lose()
	box_sprite.texture = opened
	queued = false
	#await get_tree().create_timer(3.5).timeout
	#reset_scene()

func reset_scene():
	box_sprite.texture = closed
	creature_choice_sprite.texture = null
	%GameStatus.text = ""
	%CreatureChoice.text = ""
	creature_prev.animation = "idle"


func _on_scissors_btn_button_down():
	play("scissors")

func _on_paper_btn_button_down():
	play("paper")

func _on_rock_btn_button_down():
	play("rock")
	
func _on_close_btn_button_down():
	if help_menu.visible:  # close help menu if its open
		_on_help_btn_button_down()
		return
	Globals.send_notification(Globals.NOTIFICATION_SPROCK_CLOSED)

func _on_help_btn_button_down() -> void:
	%SFX.play_sound("click")
	help_menu.visible = !help_menu.visible
