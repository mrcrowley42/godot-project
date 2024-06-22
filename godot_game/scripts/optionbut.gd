extends Button
@export var pause_game: bool = false
func _on_button_down():
	if pause_game:
		get_tree().paused = !get_tree().paused
	%OptionsMenu.visible = !%OptionsMenu.visible
