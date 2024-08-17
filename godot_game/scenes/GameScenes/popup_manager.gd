@icon("res://icons/class-icons/bell-fill.svg")
extends Node2D
@onready var toast = preload("res://scenes/UiScenes/notification.tscn")
@onready var toast2 = toast.instantiate()
# spawn notification in the horizontal centre and just above the top of screen.
@onready var start_pos = Vector2((540-toast2.size.x)/2,-toast2.size.y)
# dunno
var messages = ["random", "word", "banana", "mario", "bingus"]
var message_queue = []
var busy = false

func _ready():
	print(get_child_count())

func new_notification():
	#while get_child_count() != 0:
		#await get_tree().create_timer(2).timeout
		#if get_child_count() == 0:
			#continue
	
	var notif = toast.instantiate()
	notif.message = messages.pick_random()
	notif.position = start_pos
	add_child(notif)

func clear_queue():
	busy = false


#func _on_button_button_down():
	#if not busy:
		#busy = true
		#var notif = toast.instantiate()
		#notif.connect("complete", clear_queue)
		#notif.message = messages.pick_random()
		#notif.position = start_pos
		#add_child(notif)
#
#
#
#func clear_queue():
	#print("23")
	#busy = false


func _on_button_button_down():
	new_notification()
