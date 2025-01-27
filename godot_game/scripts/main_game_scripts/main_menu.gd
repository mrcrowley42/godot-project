class_name MainMenu extends ScriptNode


func _ready() -> void:
	pass # Replace with function body.


func _on_quit_btn_button_down() -> void:
	get_tree().quit()


func _on_continue_btn_button_down() -> void:
	Globals.change_to_scene("res://scenes/GameScenes/main.tscn")


func _on_new_game_btn_button_down() -> void:
	Globals.change_to_scene("res://scenes/GameScenes/egg_opening.tscn")


func _on_load_btn_button_down() -> void:
	# SHOW POPUP OF AVAILABLE SAVES
	pass # Replace with function body.
