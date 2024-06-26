extends TextureButton
@export var palettes: Array[Texture2D]
@onready var food_menu = %SaveControls
@onready var options_menu = %OptionsMenu

func _on_button_down():
	if not options_menu.visible:
		food_menu.visible = !food_menu.visible
