extends Button

@onready var options_menu = %OptionsMenu
@onready var btn_sfx = %BtnClick

func _on_button_down():
	btn_sfx.play()
	options_menu.return_to_main()
