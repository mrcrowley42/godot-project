extends Node2D

func _on_back_button_down():
	%BtnClick.play()
	%MainMusic.cycle_backwards()


func _on_forward_button_down():
	%BtnClick.play()
	%MainMusic.cycle_forward()
