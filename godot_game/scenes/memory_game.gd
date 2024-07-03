@icon("res://icons/controller-icon.svg")
extends Node
@onready var og_text = %ScoreLabel.text

## Class that describes the cards (buttons) for memory.
class Card extends Button:
	var hidden_value
	func _init(value):
		text = "?"
		hidden_value = value
		theme = load("res://themes/monospace_font.tres")
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	func _pressed():
		text = hidden_value


var creature_score: int = 0
var player_score: int = 0
var possible = Array(range(20))

func _process(_delta):
	%ScoreLabel.text = og_text % [player_score, creature_score]

func create_deck():
	var deck: Array = []
	for i in range(10):
		for j in range(2):
			var card = Card.new(str(possible[i]))
			deck.append(card)
	return deck

func _ready():
	var deck = create_deck()
	deck.shuffle()
	for card in deck:
		%CardGrid.add_child(card)
	
		
		#%CardGrid.add_child(card)
