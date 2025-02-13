extends CheckBox

func _ready() -> void:
	button_pressed = DataGlobals.get_global_metadata_value(DataGlobals.HOLIDAY_MODE)

func _on_toggled(toggled_on: bool) -> void:
	DataGlobals.set_metadata_value(true, DataGlobals.HOLIDAY_MODE, toggled_on)
