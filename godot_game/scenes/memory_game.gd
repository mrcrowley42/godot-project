@icon("res://icons/controller-icon.svg")
extends Node
@onready var og_text = %ScoreLabel.text

var creature_score: int = 0
var player_score: int = 0

func _process(_delta):
	%ScoreLabel.text = og_text % [player_score, creature_score]
