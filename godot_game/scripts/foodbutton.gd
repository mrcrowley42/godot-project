extends TextureButton
@export var palettes: Array[Texture2D]
@onready var food_menu = %SaveControls

func _on_button_down():
	food_menu.visible = !food_menu.visible
