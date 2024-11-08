class_name MemoryGameManager extends Node2D


func _on_help_btn_button_down() -> void:
	pass # Replace with function body.

func _on_close_btn_button_down():
	get_tree().root.propagate_notification(Globals.NOTIFICATION_MEMORY_MATCH_CLOSE)
