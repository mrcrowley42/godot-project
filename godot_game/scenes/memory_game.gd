@icon("res://icons/controller-icon.svg")
extends Node
@onready var og_text = %ScoreLabel.text

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
