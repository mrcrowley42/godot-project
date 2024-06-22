extends TextureButton
@export var palettes: Array[Texture2D]
@onready var act_menu = %KillControls

func _on_button_down():
	act_menu.visible = !act_menu.visible
