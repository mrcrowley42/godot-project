extends TextureButton


@onready var act_menu = %ActivityMenu
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	options_menu.hide()
	act_menu.visible = !act_menu.visible
