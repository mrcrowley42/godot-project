@icon("res://icons/class-icons/controller-icon.svg")
class_name MiniGameLogic extends Node

func close_game():
	Globals.send_notification(Globals.NOTIFICATION_MINIGAME_CLOSED)
	find_parent("MiniGame").queue_free()
