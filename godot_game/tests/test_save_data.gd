extends GutTest

## Must be called at the beginning of tests
func set_test_dir():
	remove_test_save_data()
	DataGlobals.use_test_file = true

## (Optional) Call at the end of tests
func remove_test_save_data():
	if FileAccess.file_exists(DataGlobals.TEST_SAVE_FILE):
		var d = DirAccess.open("res://")
		d.remove(DataGlobals.TEST_SAVE_FILE)

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

func test_save_metadata_only():
	pass
