extends TextureButton
@export var palettes: Array[Texture2D]
@onready var food_menu = %FoodControls
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	texture_pressed = load(texture_normal.resource_path.trim_suffix(".png") + "_pressed.png")
	if not options_menu.visible:
		food_menu.visible = !food_menu.visible
