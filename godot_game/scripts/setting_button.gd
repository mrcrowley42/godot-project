extends TextureButton


func _on_button_down():
	%BtnClick.play()
	texture_pressed = load(texture_normal.resource_path.trim_suffix(".png") + "_pressed.png")
	%OptionsMenu.visible = ! %OptionsMenu.visible
