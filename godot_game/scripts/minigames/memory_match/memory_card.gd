class_name MemoryCard extends Node2D

@onready var back: Button = find_child("CardBack")
@onready var front: Button = find_child("CardFront")

var VALUE_TO_IMAGE = {
	0: load("res://images/memory_match/memory_circle.png"),
	1: load("res://images/memory_match/memory_cloud.png"),
	2: load("res://images/memory_match/memory_clover.png"),
	3: load("res://images/memory_match/memory_droplet.png"),
	4: load("res://images/memory_match/memory_heart.png"),
	5: load("res://images/memory_match/memory_kite.png"),
	6: load("res://images/memory_match/memory_magenta_dye.png"),
	7: load("res://images/memory_match/memory_pentagon.png"),
	8: load("res://images/memory_match/memory_square.png"),
	9: load("res://images/memory_match/memory_triangle.png"),
}

var parent: MemoryGameLogic
var card_value: int


func _ready() -> void:
	visible = false

func init(parent_node: MemoryGameLogic, value: int):
	self.parent = parent_node
	self.card_value = value
	
	front.icon = VALUE_TO_IMAGE[value]

func flip_card():
	pass
