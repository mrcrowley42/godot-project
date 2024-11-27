extends GutTest

## ---------------
##    METADATA
## ---------------

## test metadata_only saves only metadata
func test_save_metadata_only():
	Testing.setup_test_environment(self)
	
	assert_false(DataGlobals.has_save_data())
	assert_eq(DataGlobals.get_current_metadata_dc(), {})
	
	# save metadata
	DataGlobals.save_only_metadata()
	var expected = DataGlobals.get_default_metadata()
	expected[DataGlobals.LAST_SAVED] = 0
	assert_true(DataGlobals.has_save_data())
	assert_true(DataGlobals.has_only_metadata())
	
	# read and compare
	var save_file := FileAccess.open(DataGlobals.get_save_data_file(), FileAccess.READ)
	var first_line = JSON.parse_string(save_file.get_line())
	first_line[DataGlobals.LAST_SAVED] = 0
	assert_same(str(first_line), str(expected))

## test metadata is overridden when set in the override dict
#func test_metadata_to_override():
	#Testing.setup_test_environment(self)
	#
	#DataGlobals.save_only_metadata()
	#var old = DataGlobals.get_current_metadata_dc()
	#assert_eq(old[DataGlobals.CURRENT_CREATURE], str(null))
	#
	## override
	#DataGlobals.metadata_to_override[DataGlobals.CURRENT_CREATURE] = "creature1"
	#DataGlobals.save_only_metadata()
	#var new = DataGlobals.metadata_last_loaded
	#assert_eq(new[DataGlobals.CURRENT_CREATURE], "creature1")
	#
	## override again
	#DataGlobals.metadata_to_override[DataGlobals.CURRENT_CREATURE] = "creature2"
	#DataGlobals.save_only_metadata()
	#var newer = DataGlobals.metadata_last_loaded
	#assert_eq(newer[DataGlobals.CURRENT_CREATURE], "creature2")
	#
	## check override is retained
	#DataGlobals.save_only_metadata()
	#var retained = DataGlobals.metadata_last_loaded
	#assert_eq(retained[DataGlobals.CURRENT_CREATURE], "creature2")
#
### test metadata is add to when set in the add dict
#func test_metadata_to_add():
	#Testing.setup_test_environment(self)
	#
	#DataGlobals.save_only_metadata()
	#var old = DataGlobals.metadata_last_loaded
	#assert_eq(old[DataGlobals.CREATURES_DISCOVERED], [])
	#
	## set first item
	#DataGlobals.metadata_to_add[DataGlobals.CREATURES_DISCOVERED] = ["creature1"]
	#DataGlobals.save_only_metadata()
	#var new = DataGlobals.metadata_last_loaded
	#assert_eq(new[DataGlobals.CREATURES_DISCOVERED], ["creature1"])
	#
	## append second & third item
	#DataGlobals.metadata_to_add[DataGlobals.CREATURES_DISCOVERED] = ["creature2", "creature3"]
	#DataGlobals.save_only_metadata()
	#var newer = DataGlobals.metadata_last_loaded
	#assert_eq(newer[DataGlobals.CREATURES_DISCOVERED], ["creature1", "creature2", "creature3"])


## ----------------
##    SAVE DATA
## ----------------

## test nodes with save group are saved
func test_save_node_data():
	Testing.setup_test_environment(self)
	
	var node := Testing.TestNode.new()
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
	Testing.setup_test_environment(self)
	
	var node := Testing.TestNode.new()
	add_child(node)
	assert_eq(node.data_loaded, null)
	
	# save & load
	DataGlobals.save_data()
	assert_true(DataGlobals.has_save_data())
	DataGlobals.load_data()
	
	var save_file := FileAccess.open(DataGlobals.get_save_data_file(), FileAccess.READ)
	var first_line = JSON.parse_string(save_file.get_line())
	assert_same(str(first_line), str(DataGlobals.get_current_metadata_dc()))
	assert_eq(str(node.data_loaded), str(node.data_to_save))
