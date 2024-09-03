extends TextureButton

@export var target_menu: Node
@onready var options_menu = %OptionsMenu

func _on_button_down():
	%BtnClick.play()
	options_menu.hide()
	target_menu.visible = !target_menu.visible
