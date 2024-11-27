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

func test_metadata_set():
	Testing.setup_test_environment(self)
	assert_eq("", DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE))
	
	var uid = "123"
	DataGlobals.set_metadata_value(DataGlobals.CURRENT_CREATURE, uid)
	assert_eq(uid, DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE))

func test_metadata_add():
	Testing.setup_test_environment(self)
	assert_eq("", DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE))
	
	DataGlobals.set_metadata_value(DataGlobals.CURRENT_CREATURE, 1)
	var value = DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE)
	assert_typeof(value, TYPE_STRING)
	assert_eq(1, int(value))
	
	DataGlobals.add_to_metadata_value(DataGlobals.CURRENT_CREATURE, 2)
	var new_value = DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE)
	assert_typeof(new_value, TYPE_STRING)
	assert_eq(3, int(new_value))

func test_metadata_append():
	Testing.setup_test_environment(self)
	assert_eq([], DataGlobals.get_metadata_value(DataGlobals.UNLOCKED_THEMES))
	
	DataGlobals.append_to_metadata_value(DataGlobals.UNLOCKED_THEMES, "theme1")
	assert_eq(["theme1"], DataGlobals.get_metadata_value(DataGlobals.UNLOCKED_THEMES))
	
	DataGlobals.append_to_metadata_value(DataGlobals.UNLOCKED_THEMES, "theme2")
	DataGlobals.append_to_metadata_value(DataGlobals.UNLOCKED_THEMES, "theme3")
	assert_eq(["theme1", "theme2", "theme3"], DataGlobals.get_metadata_value(DataGlobals.UNLOCKED_THEMES))

func test_metadata_modify():
	Testing.setup_test_environment(self)
	assert_eq({}, DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED))
	
	# set
	var uid = "123"
	var val = {"data": 1}
	var expected = {uid: val.duplicate(true)}
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid], DataGlobals.ACTION_SET, val)
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))
	
	# add
	var addition = 2
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid, "data"], DataGlobals.ACTION_ADD, addition)
	expected[uid]["data"] += addition
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))
	
	# append
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid, "list"], DataGlobals.ACTION_SET, [])
	expected[uid]["list"] = []
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))
	
	var one = "item1"
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid, "list"], DataGlobals.ACTION_APPEND, one)
	expected[uid]["list"].append(one)
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))
	
	var two = "two"
	var three = "three"
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid, "list"], DataGlobals.ACTION_APPEND, two)
	DataGlobals.modify_metadata_value(DataGlobals.CREATURES_DISCOVERED, [uid, "list"], DataGlobals.ACTION_APPEND, three)
	expected[uid]["list"].append(two)
	expected[uid]["list"].append(three)
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))
	
	# save to file & load from file & recheck
	DataGlobals.save_only_metadata()
	DataGlobals.load_metadata()
	assert_eq(str(expected), str(DataGlobals.get_metadata_value(DataGlobals.CREATURES_DISCOVERED)))


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
