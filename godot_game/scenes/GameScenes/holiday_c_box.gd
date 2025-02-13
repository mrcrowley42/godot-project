extends CheckBox

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		button_pressed = DataGlobals.get_global_metadata_value(DataGlobals.HOLIDAY_MODE)

func _on_toggled(toggled_on: bool) -> void:
	DataGlobals.set_metadata_value(true, DataGlobals.HOLIDAY_MODE, toggled_on)
