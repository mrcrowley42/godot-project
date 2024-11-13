class_name MemoryCard extends Control

@onready var back: Button = find_child("CardBack")
@onready var front: Button = find_child("CardFront")
@onready var locked: Button = find_child("CardLocked")

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

const LARGE_SCALE = Vector2(1.1, 1.1)

var parent: MemoryGameLogic
var card_value: int
var is_flipped: bool = false


func _ready() -> void:
	visible = true
	front.visible = false
	back.visible = false
	locked.visible = false

func init(parent_node: MemoryGameLogic, value: int, timer: Timer = null):
	self.parent = parent_node
	self.card_value = value
	front.icon = VALUE_TO_IMAGE[value]
	
	if timer != null:
		timer.connect("timeout", place_card)
	else:
		place_card()

func place_card():
	back.visible = true
	do_pulse()

func do_pulse():
	scale = LARGE_SCALE
	Globals.tween(self, "scale", Vector2(1, 1), 0., .3)

## flip card bool & animation
func flip_card():
	is_flipped = !is_flipped
	await visual_flip()
	back.visible = !back.visible
	front.visible = !front.visible

func visual_flip():
	Globals.tween(self, "scale", LARGE_SCALE, 0., .3)
	
	await get_tree().create_timer(.1).timeout
	Globals.tween(self, "scale", Vector2(0, 1), 0., .3)
	
	await get_tree().create_timer(.15).timeout
	Globals.tween(self, "scale", Vector2(1, 1), 0., .3)

func lock_card_in():
	Globals.tween(self, "scale", LARGE_SCALE, 0., .3)
	
	await get_tree().create_timer(.1).timeout
	Globals.tween(self, "scale", Vector2(1, 1), 0., .3, Tween.EASE_IN)
	
	await get_tree().create_timer(.3).timeout
	back.visible = false
	locked.visible = true
	front.flat = true

func _on_card_back_button_down() -> void:
	if !is_flipped and (!parent.card_a or !parent.card_b):
		flip_card()
		parent.card_flipped(self)
