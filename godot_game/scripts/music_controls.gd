extends Node2D

## back
func _on_left_button_down() -> void:
	%BtnClick.play()
	%MainMusic.cycle_backwards()

## next
func _on_right_button_down() -> void:
	%BtnClick.play()
	%MainMusic.cycle_forward()
