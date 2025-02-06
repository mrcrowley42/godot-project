extends Control


@export var cosmetics_grid: GridContainer
@export var line_edit: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_edit_creature_name_button_down() -> void:
	show()
	cosmetics_grid.hide()
	line_edit.text = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME)


func _on_cancel_edit_btn_button_down() -> void:
	hide()
	cosmetics_grid.show()


func _on_accept_edit_btn_button_down() -> void:
	hide()
	cosmetics_grid.show()
	var new_name = line_edit.text
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_NAME, new_name)
	cosmetics_grid.update_title()
