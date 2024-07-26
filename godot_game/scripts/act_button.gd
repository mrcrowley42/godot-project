extends TextureButton

@export var palettes: Array[Texture2D]
@onready var act_menu = %ActivityMenu
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	texture_pressed = load(texture_normal.resource_path.trim_suffix(".png") + "_pressed.png")
	options_menu.hide()
	act_menu.visible = !act_menu.visible
