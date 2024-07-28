extends TextureButton

@onready var food_menu = %FoodMenu
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	options_menu.hide()
	food_menu.visible = !food_menu.visible
