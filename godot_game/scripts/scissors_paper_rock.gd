extends MiniGameLogic
@onready var og_text = %ScoreLabel.text

var creature_score: int = 0
var player_score: int = 0
var choices = ['rock', 'paper', 'scissors']

func _process(_delta):
	%ScoreLabel.text = og_text % [player_score, creature_score]

func win():
	player_score += 1
	%GameStatus.text = 'Victory\nYou win'
	%SFX.play_sound("correct")
	
func lose():
	creature_score += 1
	%GameStatus.text = 'Defeat\nCreature wins'
	%SFX.play_sound("wrong")
	
func play(user_choice):
	var creature_choice = choices.pick_random()
	%CreatureChoice.text = str('Creature chose ' + creature_choice)
#
	if creature_choice == user_choice:
		%GameStatus.text = 'Draw\nNeither wins'
		%SFX.play_sound("draw")
	elif user_choice == 'rock' and creature_choice == 'scissors':
		win()

	elif user_choice == 'paper' and creature_choice == 'rock':
		win()

	elif user_choice == 'scissors' and creature_choice == 'paper':
		win()
		
	else: lose()

func _on_scissors_btn_button_down():
	play("scissors")

func _on_paper_btn_button_down():
	play("paper")

func _on_rock_btn_button_down():
	play("rock")
