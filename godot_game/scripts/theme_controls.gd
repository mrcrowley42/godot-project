extends Node2D

func _on_forward_button_down():
	%BtnClick.play()
	%UI_Overlay.cycle_forward()

func _on_back_button_down():
	%BtnClick.play()
	%UI_Overlay.cycle_backwards()
