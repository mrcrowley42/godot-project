@icon("res://icons/controller-icon.svg")

extends Node
@onready var og_text = %ScoreLabel.text

var selected_cards: Array[MemCard] = []
var creature_score: int = 0
var player_score: int = 0
var possible = Array(range(20))
var complete: bool = false

## Class that describes the cards (buttons) for memory.
class MemCard extends Button:
	var hidden_value
	func _init(value):
		text = "?"
		hidden_value = value
		theme = load("res://themes/action_btn.tres")
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	func _pressed():
		find_parent("GameLogic").choose_card(self)
		
	func flip_card():
		if text == "?":
			text = hidden_value
		elif text != "X":
			text = "?"

func _process(_delta):
	%ScoreLabel.text = og_text % [player_score, creature_score]
	
	if player_score == 10:
		if not complete:
			%Confetti.confet()
			complete = true

func create_deck() -> Array:
	var deck: Array = []
	for i in range(10):
		for j in range(2):
			var card = MemCard.new(str(possible[i]))
			deck.append(card)
	return deck

func _ready():
	var deck = create_deck()
	deck.shuffle()
	for card in deck:
		%CardGrid.add_child(card)

func choose_card(card):
	if selected_cards.size() < 3:
		selected_cards.append(card)
		card.flip_card()
		card.disabled = true
		
	if selected_cards.size() == 2:
		if selected_cards[0].hidden_value == selected_cards[1].hidden_value:
			player_score += 1
			for item in selected_cards:
				item.text = "X"
				item.disabled = true
			%SFX.play_sound("correct")
		else:
			await get_tree().create_timer(.45).timeout
			for item in selected_cards:
				item.flip_card()
				item.disabled = false
			%SFX.play_sound("wrong")
			
		selected_cards.clear()
