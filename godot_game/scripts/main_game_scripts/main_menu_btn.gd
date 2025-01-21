extends Button


func _on_button_down() -> void:
	await Globals.perform_closing_transition(owner.trans_img, owner.ui_overlay.position)
	Globals.change_to_scene("res://scenes/GameScenes/main_menu.tscn")
