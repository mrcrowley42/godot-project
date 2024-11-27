extends GutTest

## -----------------
##   ENVIRON TESTS
## -----------------

## Test the games' save data file is not used for tests
func test_save_data_file_is_segregated():
	assert_false(Testing.is_test_environ)
	assert_eq(DataGlobals.get_save_data_file(), Globals.SAVE_DATA_FILE)
	
	# setup test environment
	Testing.setup_test_environment(self)
	assert_true(Testing.is_test_environ)
	assert_eq(DataGlobals.get_save_data_file(), Testing.TEST_SAVE_FILE)
	assert_false(FileAccess.file_exists(Testing.TEST_SAVE_FILE))
	
	# create save data file
	DataGlobals.save_only_metadata()
	assert_true(FileAccess.file_exists(Testing.TEST_SAVE_FILE))
	
	Testing.remove_test_save_data()
	assert_false(FileAccess.file_exists(Testing.TEST_SAVE_FILE))
