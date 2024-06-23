extends Node2D

func _on_back_button_down():
	%MainMusic.cycle_backwards()


func _on_forward_button_down():
	%MainMusic.cycle_forward()
