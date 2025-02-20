extends Control


@export var cosmetics_grid: GridContainer
@export var line_edit: LineEdit
@export var ach_man: AchievementManager
@export var change_name_ach: Achievement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_edit_creature_name_button_down() -> void:
	%BtnClick.play()
	show()
	cosmetics_grid.hide()
	line_edit.text = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME)


func _on_cancel_edit_btn_button_down() -> void:
	%BtnClick.play()
	hide()
	cosmetics_grid.show()


func _on_accept_edit_btn_button_down() -> void:
	%BtnClick.play()
	hide()
	cosmetics_grid.show()
	var old_name = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME)
	var new_name = line_edit.text
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_NAME, new_name)
	cosmetics_grid.update_title()
	
	if old_name != new_name:
		Globals.unlock_achievement(change_name_ach)
		ach_man.customise_everything_counter(ach_man.CUSTOMISATIONS.NAME)
