extends Button


func _on_button_down() -> void:
	Globals.send_notification(Globals.NOTIFICATION_QUIT_TO_MAIN_MENU)
