extends MarginContainer

@onready var btn_sfx = find_parent("MainMenu").find_child("BtnClick")

func _ready() -> void:
	visible = false


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		pass
		#add_saves()

func _on_back_button_down() -> void:
	btn_sfx.play()
	self.hide()


func _on_wipe_save_btn_button_down() -> void:
	pass
	#var d = DirAccess.open("res://")
	#d.remove(Globals.SAVE_DATA_FILE)
	#get_tree().quit()



func _on_hidden() -> void:
	DataGlobals.save_settings_data()
	pass # Replace with function body.
