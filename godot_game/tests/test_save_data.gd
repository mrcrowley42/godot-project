extends GutTest


## --------------
##   "FIXTURES"
## --------------

## Must be called at the beginning of tests
func set_test_dir():
	remove_test_save_data()
	DataGlobals.setup_test_environ()
	
	assert_eq(DataGlobals.get_save_data_file(), DataGlobals.TEST_SAVE_FILE)

## (Optional) Call at the end of tests
func remove_test_save_data():
	if FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE):
		var d = DirAccess.open("res://")
		d.remove(DataGlobals.TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))


## ------------
##    TESTS
## ------------

## Test the games' save data file is not used for tests
func test_save_data_file_is_segregated():
	assert_false(DataGlobals.use_test_file)
	assert_eq(DataGlobals.get_save_data_file(), Globals.SAVE_DATA_FILE)
	
	set_test_dir()
	assert_true(DataGlobals.use_test_file)
	assert_eq(DataGlobals.get_save_data_file(), DataGlobals.TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))
	
	DataGlobals.save_only_metadata()
	assert_true(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))
	
	remove_test_save_data()
	assert_false(FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE))

## test metadata_only saves only metadata
func test_save_metadata_only():
	set_test_dir()
	
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
	set_test_dir()
	
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
	
	# check override is retained on next save
	DataGlobals.save_only_metadata()
	var retained = DataGlobals.metadata_last_loaded
	assert_eq(retained[DataGlobals.CURRENT_CREATURE], "creature2")

## test metadata is add to when set in the add dict
func test_metadata_to_add():
	set_test_dir()
	
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
