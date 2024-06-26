extends TextureButton
@export var palettes: Array[Texture2D]
@onready var act_menu = %KillControls
@onready var options_menu = %OptionsMenu

func _on_button_down():
	if not options_menu.visible:
		act_menu.visible = !act_menu.visible
