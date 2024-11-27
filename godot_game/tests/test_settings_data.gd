extends GutTest

## -----------------
##   SETTING TESTS
## -----------------

## test settings data is saved
func test_save_settings_data():
	Testing.setup_test_environment(self)
	
	var node := Testing.TestNode.new(true)
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

## test settings data is saved with sections
func test_save_settings_data_sections():
	Testing.setup_test_environment(self)
	
	var node := Testing.TestNode.new(true)
	node.use_setting_data = true
	add_child(node)
	
	assert_false(DataGlobals.has_settings_data())
	DataGlobals.save_settings_data()
	assert_true(DataGlobals.has_settings_data())
	
	var expected = node.setting_data_to_save
	var settings_file := FileAccess.open(DataGlobals.get_settings_file(), FileAccess.READ)
	var first_line = settings_file.get_line()
	assert_eq(first_line.replace('[', '').replace(']', ''), expected["section"])
	
	var second_line = settings_file.get_line()
	assert_eq(second_line, "")
	
	var third_line = settings_file.get_line()
	var key = expected.keys()[1]
	assert_same(third_line, "%s=%s" % [key, str(expected[key])])


## test settings data is loaded
func test_load_settings_data():
	Testing.setup_test_environment(self)
	
	var node = Testing.TestNode.new(true)
	add_child(node)
	assert_eq(node.data_loaded, null)
	
	DataGlobals.save_settings_data()
	assert_true(DataGlobals.has_settings_data())
	DataGlobals.load_settings_data()
	
	assert_eq(node.data_loaded, node.data_to_save)

## test settings data is loaded with a section
func test_load_settings_data_section():
	Testing.setup_test_environment(self)
	
	var node = Testing.TestNode.new(true)
	node.use_setting_data = true
	add_child(node)
	assert_eq(node.data_loaded, null)
	
	DataGlobals.save_settings_data()
	assert_true(DataGlobals.has_settings_data())
	DataGlobals.load_settings_data()
	
	assert_eq(node.data_loaded, node.setting_data_to_save)
