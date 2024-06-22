extends TextureButton
@export var palettes: Array[Texture2D]

func _on_button_down():
	%KillControls.show()
