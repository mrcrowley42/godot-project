@icon("res://icons/class-icons/controller-icon.svg")
class_name MiniGameLogic extends Node

func close_game():
	get_tree().root.propagate_notification(Globals.NOTIFICATION_MEMORY_MATCH_CLOSE)
