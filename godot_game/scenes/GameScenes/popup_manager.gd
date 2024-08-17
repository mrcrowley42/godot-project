@icon("res://icons/class-icons/bell-fill.svg")
extends Node2D
@onready var toast = preload("res://scenes/UiScenes/notification.tscn")
@onready var toast2 = toast.instantiate()
# spawn notification in the horizontal centre and just above the top of screen.
@onready var start_pos = Vector2((540-toast2.size.x)/2,-toast2.size.y+112)

func new_notification(message):
	while get_child_count() != 0:
		await get_tree().create_timer(1).timeout
		if get_child_count() == 0:
			continue

	var notif = toast.instantiate()
	notif.message = message
	notif.position = start_pos
	add_child(notif)
