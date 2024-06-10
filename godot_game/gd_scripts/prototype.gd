extends Node


func _input(event):
	# close when `esc` key is pressed
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_button_2_button_down():
	pass # Replace with function body.
