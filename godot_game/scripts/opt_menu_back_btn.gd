extends Button

@onready var options_menu = %OptionsMenu
@onready var btn_sfx = %BtnClick

func _on_button_down(to_settings=false):
	btn_sfx.play()
	DataGlobals.save_settings_data()
	if to_settings:
		options_menu.return_to_settings()
	else:
		options_menu.return_to_main()
