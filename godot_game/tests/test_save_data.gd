extends GutTest


## --------------
##   "FIXTURES"
## --------------

## Must be called at the beginning of tests
func setup_test_environment():
	remove_test_save_data()
	remove_test_settings_data()
	DataGlobals.setup_test_environ()
	assert_eq(DataGlobals.get_save_data_file(), DataGlobals.TEST_SAVE_FILE)
	assert_eq(DataGlobals.get_settings_file(), DataGlobals.TEST_SETTINGS_FILE)
	
	# remove all children
	for child in get_children():
		remove_child(child)
	assert_eq(get_children(), [])

## Deletes save data file
func remove_test_save_data():
	if FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE):
		var d = DirAccess.open("res://")
		d.remove(DataGlobals.TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))

## Deletes settings file
func remove_test_settings_data():
	if FileAccess.file_exists(DataGlobals.TEST_SETTINGS_FILE):
		var d = DirAccess.open("res://")
		d.remove(DataGlobals.TEST_SETTINGS_FILE)
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SETTINGS_FILE))

## a node to use for saving
class TestNode extends Node2D:
	var data_to_save = {"some_data": [54, 1, 2]}
	var data_loaded = null
	
	func _init(settings_group=false) -> void:
		if settings_group:
			add_to_group("settings_data")
		else:
			add_to_group("save_data")
	func save():
		return data_to_save
	func load(data):
		data_loaded = data

## ------------
##    TESTS
## ------------

## Test the games' save data file is not used for tests
func test_save_data_file_is_segregated():
	assert_false(DataGlobals.use_test_file)
	assert_eq(DataGlobals.get_save_data_file(), Globals.SAVE_DATA_FILE)
	
	# setup test environment
	setup_test_environment()
	assert_true(DataGlobals.use_test_file)
	assert_eq(DataGlobals.get_save_data_file(), DataGlobals.TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))
	
	# create save data file
	DataGlobals.save_only_metadata()
	assert_true(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))
	
	remove_test_save_data()
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))

## test metadata_only saves only metadata
func test_save_metadata_only():
	setup_test_environment()
	
	assert_false(DataGlobals.has_save_data())
	assert_eq(DataGlobals.metadata_last_loaded, {})
	
	# save metadata
	DataGlobals.save_only_metadata()
	var expected = DataGlobals.metadata_last_loaded
	assert_true(DataGlobals.has_save_data())
	assert_true(DataGlobals.has_only_metadata())
	
	# read and compare
	var save_file := FileAccess.open(DataGlobals.get_save_data_file(), FileAccess.READ)
	var first_line = JSON.parse_string(save_file.get_line())
	assert_same(str(first_line), str(expected))

## test metadata is overridden when set in the override dict
func test_metadata_to_override():
	setup_test_environment()
	
	DataGlobals.save_only_metadata()
	var old = DataGlobals.metadata_last_loaded
	assert_eq(old[DataGlobals.CURRENT_CREATURE], str(null))
	
	# override
	DataGlobals.metadata_to_override[DataGlobals.CURRENT_CREATURE] = "creature1"
	DataGlobals.save_only_metadata()
	var new = DataGlobals.metadata_last_loaded
	assert_eq(new[DataGlobals.CURRENT_CREATURE], "creature1")
	
	# override again
	DataGlobals.metadata_to_override[DataGlobals.CURRENT_CREATURE] = "creature2"
	DataGlobals.save_only_metadata()
	var newer = DataGlobals.metadata_last_loaded
	assert_eq(newer[DataGlobals.CURRENT_CREATURE], "creature2")
	
	# check override is retained
	DataGlobals.save_only_metadata()
	var retained = DataGlobals.metadata_last_loaded
	assert_eq(retained[DataGlobals.CURRENT_CREATURE], "creature2")

## test metadata is add to when set in the add dict
func test_metadata_to_add():
	setup_test_environment()
	
	DataGlobals.save_only_metadata()
	var old = DataGlobals.metadata_last_loaded
	assert_eq(old[DataGlobals.CREATURES_DISCOVERED], [])
	
	# set first item
	DataGlobals.metadata_to_add[DataGlobals.CREATURES_DISCOVERED] = ["creature1"]
	DataGlobals.save_only_metadata()
	var new = DataGlobals.metadata_last_loaded
	assert_eq(new[DataGlobals.CREATURES_DISCOVERED], ["creature1"])
	
	# append second & third item
	DataGlobals.metadata_to_add[DataGlobals.CREATURES_DISCOVERED] = ["creature2", "creature3"]
	DataGlobals.save_only_metadata()
	var newer = DataGlobals.metadata_last_loaded
	assert_eq(newer[DataGlobals.CREATURES_DISCOVERED], ["creature1", "creature2", "creature3"])

## test nodes with save group are saved
func test_save_node_data():
	setup_test_environment()
	
	var node := TestNode.new()
	add_child(node)
	
	assert_false(DataGlobals.has_save_data())
	assert_false(DataGlobals.has_only_metadata())
	DataGlobals.save_data()
	assert_true(DataGlobals.has_save_data())
	assert_false(DataGlobals.has_only_metadata())
	
	var save_file := FileAccess.open(DataGlobals.get_save_data_file(), FileAccess.READ)
	var first_line = JSON.parse_string(save_file.get_line())
	assert_same(str(first_line), str(DataGlobals.load_metadata()))
	
	var second_line = JSON.parse_string(save_file.get_line())
	assert_eq(second_line[DataGlobals.PATH], str(node.get_path()))
	assert_eq(str(second_line[DataGlobals.DATA]), str(node.data_to_save))

## test data saved is loaded to the nodes
func test_load_node_data():
	setup_test_environment()
	
	var node := TestNode.new()
	add_child(node)
	assert_eq(node.data_loaded, null)
	
	# save & load
	DataGlobals.save_data()
	assert_true(DataGlobals.has_save_data())
	DataGlobals.load_data()
	
	var save_file := FileAccess.open(DataGlobals.get_save_data_file(), FileAccess.READ)
	var first_line = JSON.parse_string(save_file.get_line())
	assert_same(str(first_line), str(DataGlobals.metadata_last_loaded))
	assert_eq(str(node.data_loaded), str(node.data_to_save))

## test settings data is saved
func test_save_settings_data():
	setup_test_environment()
	
	var node := TestNode.new(true)
	add_child(node)
	
	assert_false(DataGlobals.has_settings_data())
	DataGlobals.save_settings_data()
	assert_true(DataGlobals.has_settings_data())
	
	var settings_file := FileAccess.open(DataGlobals.get_settings_file(), FileAccess.READ)
	var first_line = settings_file.get_line()
	assert_eq(first_line, "[general]")
	
	var second_line = settings_file.get_line()
	assert_eq(second_line, "")
	
	var third_line = settings_file.get_line()
	var key = node.data_to_save.keys()[0]
	assert_same(third_line, "%s=%s" % [key, str(node.data_to_save[key])])

## test settings data is loaded
func test_load_settings_data():
	setup_test_environment()
	
	var node := TestNode.new(true)
	add_child(node)
	assert_eq(node.data_loaded, null)
	
	DataGlobals.save_settings_data()
	assert_true(DataGlobals.has_settings_data())
	DataGlobals.load_settings_data()
	
	assert_eq(node.data_loaded, node.data_to_save)
