class_name MemoryCard extends Node2D


var parent: MemoryGameLogic
var card_value: int


func init(parent_node: MemoryGameLogic, value: int):
	self.parent = parent_node
	self.card_value = value

func flip_card():
	pass
