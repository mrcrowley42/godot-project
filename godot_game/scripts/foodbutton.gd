extends TextureButton

@onready var food_menu = %FoodMenu
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	texture_pressed = load(texture_normal.resource_path.trim_suffix(".png") + "_pressed.png")
	options_menu.hide()
	food_menu.visible = !food_menu.visible
