extends TextureButton


func _on_button_down():
	%BtnClick.play()
	%OptionsMenu.visible = ! %OptionsMenu.visible
	%SettingsMenu.visible = false
