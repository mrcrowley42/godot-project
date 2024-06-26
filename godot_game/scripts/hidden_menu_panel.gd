extends PanelContainer

func _ready():
	self.visible = false


func _on_cancel_button_down():
	%OptionsMenu.visible = !%OptionsMenu.visible
