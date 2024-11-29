extends GutTest

var is_test_environ: bool = false

const TEST_SAVE_FILE = "res://tests/save_data_test.save"
const TEST_SETTINGS_FILE = "res://tests/settings_test.cfg"

## --------------
##   "FIXTURES"
## --------------

## Must be called at the beginning of tests
func setup_test_environment(parent):
	remove_test_save_data()
	remove_test_settings_data()
	
	is_test_environ = true
	DataGlobals._current_metadata.clear()  # clear potentially set values
	
	assert_eq(DataGlobals.get_save_data_file(), TEST_SAVE_FILE)
	assert_eq(DataGlobals.get_settings_file(), TEST_SETTINGS_FILE)
	
	remove_child_nodes(parent)

## Deletes save data file
func remove_test_save_data():
	if FileAccess.file_exists(TEST_SAVE_FILE):
		var d = DirAccess.open("res://")
		d.remove(TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(TEST_SAVE_FILE))

## Deletes settings file
func remove_test_settings_data():
	if FileAccess.file_exists(TEST_SETTINGS_FILE):
		var d = DirAccess.open("res://")
		d.remove(TEST_SETTINGS_FILE)
	assert_false(FileAccess.file_exists(TEST_SETTINGS_FILE))

func remove_child_nodes(parent):
	for child in parent.get_children():
		parent.remove_child(child)
	assert_eq(parent.get_children(), [])

## a node to use for saving
class TestNode extends Node2D:
	var data_to_save = {"some_data": [54, 1, 2]}
	var setting_data_to_save = {"section": "SomeSection", "some_data": 12345}

	var data_loaded = null
	var use_setting_data = false

	func _init(settings_group=false) -> void:
		if settings_group:
			add_to_group("settings_data")
		else:
			add_to_group("save_data")

	func get_save_uid() -> int:
		return 0

	func save():
		return setting_data_to_save if use_setting_data else data_to_save
	func load(data):
		data_loaded = data
