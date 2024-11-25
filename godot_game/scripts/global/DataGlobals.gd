extends Node

# metadata items
const LAST_SAVED = "last_saved"
const CURRENT_CREATURE = "current_creature"
const CREATURES_DISCOVERED = "creatures_discovered"
const UNLOCKED_COSMETICS = "unlocked_cosmetics"
const UNLOCKED_FACTS = "unlocked_facts"
const UNLOCKED_THEMES = "unlocked_themes"

# other
const SECTION = "section"
const PATH = "path"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"

## storage of the metadata that was last loaded from the save file
var metadata_last_loaded: Dictionary = {}

func get_save_data_file():
	return TEST_SAVE_FILE if use_test_file else Globals.SAVE_DATA_FILE

func get_settings_file():
	return TEST_SETTINGS_FILE if use_test_file else Globals.SAVE_SETTINGS_FILE

func has_save_data() -> bool:
	if FileAccess.file_exists(get_save_data_file()):
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		return save_file.get_length() > 0
	return false

func has_settings_data() -> bool:
	return FileAccess.file_exists(get_settings_file())

## does save file only contain metadata (only 1 line exists)
func has_only_metadata() -> bool:
	if has_save_data():
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		return save_file.get_length() == len(save_file.get_line())  # only one line in save file
	return false

## --------------
##    SAVING
## --------------

## set / override a value in the metadata
func set_metadata_value(metadata_key: String, value):
	if is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT):
		value = str(value)
	
	metadata_last_loaded[metadata_key] = value
	save_only_metadata()

## add / append to a value in the metadata
func add_to_metadata_value(metadata_key: String, value):
	var new_val = get_metadata_value(metadata_key)
	
	# add
	if is_instance_of(new_val, TYPE_INT) or is_instance_of(new_val, TYPE_FLOAT):
		assert(is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT))
		new_val += value
	
	# append
	if is_instance_of(new_val, TYPE_ARRAY):
		new_val.append(value)
	
	metadata_last_loaded[metadata_key] = new_val
	save_only_metadata()

## modify a dict in the metadata, action: 0=set, 1=add
## paths contain the keys to be used to navigate the dictionary value at metadata_key in the metadata
func modify_metadata_value(metadata_key: String, paths: Array[String], action: int, value):
	assert(metadata_last_loaded.has(metadata_key), "'%s' should already exist in metadata" % metadata_key)
	var dict: Dictionary = metadata_last_loaded[metadata_key]  # pointer
	
	assert(len(paths) != 0, "just use set_metadata_value() lmao")
	assert(action == 0 || action == 1, "action must be either 0 (set) or 1 (add to)")
	
	var last_path = paths.pop_back()
	for key in paths:
		assert(dict.has(key))
		dict = dict[key]
	
	if action == 0:
		dict[last_path] = value
	else:
		if is_instance_of(dict[last_path], TYPE_ARRAY):
			dict[last_path].append(value)  # append
		elif is_instance_of(dict[last_path], TYPE_INT) or is_instance_of(dict[last_path], TYPE_FLOAT):
			dict[last_path] += value  # add
		else:
			printerr("the value of metadata %s [%s, %s] is not valid for modification" % [metadata_key, paths, last_path])
	save_only_metadata()

## get value from last loaded or default if it doesn't have it
func get_metadata_value(metadata_key: String):
	var value = get_default_metadata()[metadata_key]
	if metadata_last_loaded.has(metadata_key):
		value = metadata_last_loaded[metadata_key]
	return value

func get_default_metadata() -> Dictionary:
	return {
		LAST_SAVED: Time.get_unix_time_from_system(),
		CURRENT_CREATURE: null,
		CREATURES_DISCOVERED: [],
		UNLOCKED_COSMETICS: [],
		UNLOCKED_FACTS: [],
		UNLOCKED_THEMES: []
	}

## takes into account the metadata to override and to add
func generate_metadata_to_save() -> Dictionary:
	var new_metadata = metadata_last_loaded.duplicate(true)  # deepcopy
	new_metadata[LAST_SAVED] = Time.get_unix_time_from_system()
	return new_metadata

# save file structure:
# line 1  = metadata
# line 2+ = node data  (each node is assigned its own line)
func save_data():
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var all_data = [generate_metadata_to_save()]  # metadata is first
	metadata_last_loaded = all_data[0]

	# save node data
	for node in save_nodes:
		if !node.has_method(SAVE): # object doesnt have save() func
			print("Node '%s' doesnt have a %s() function" % [node.name, SAVE])
			continue

		var node_data = {
			PATH: node.get_path(),
			DATA: node.call(SAVE)
		}
		all_data.append(JSON.stringify(node_data))

	save_file.store_string("\n".join(all_data))

## changes only the first line (the metadata line) in save file, everything else remains unchanged
func save_only_metadata():
	var file_existed = has_save_data()
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	if file_existed: save_file.get_line()  # remove old metadata

	# replace existing metadata with new
	var new_metadata = generate_metadata_to_save()
	metadata_last_loaded = new_metadata

	var all_lines = [new_metadata]
	if file_existed:  # get the rest of the file
		while save_file.get_position() < save_file.get_length():
			all_lines.append(save_file.get_line())

	save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	save_file.store_string("\n".join(all_lines))

func save_settings_data():
	var config = ConfigFile.new()
	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)

	for node in settings_nodes:
		if !node.has_method(SAVE): # object doesnt have save() func
			print("Node '%s' doesnt have a %s() function" % [node.name, SAVE])
			continue

		var data = node.call(SAVE)
		if typeof(data) != TYPE_DICTIONARY:
			print("Node '%s' save data is not of type dictionary (data: '%s'). Skipping" % [node.name, data])
			return
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION

		for key in data.keys():
			if key != SECTION:
				config.set_value(section, key, data[key])

		config.save(get_settings_file())

## --------------
##    LOADING
## --------------

## loads only the metadata line from save (if it exists)
func load_metadata() -> Dictionary:
	if has_save_data():
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		metadata_last_loaded = JSON.parse_string(save_file.get_line())
	return metadata_last_loaded

## loads data, and passes it to saved nodes. returns metadata
func load_data() -> Dictionary:
	if !has_save_data():
		return metadata_last_loaded

	# attempt to load
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	metadata_last_loaded = JSON.parse_string(save_file.get_line())

	while save_file.get_position() < save_file.get_length():
		var line = save_file.get_line()
		var parsed_line = JSON.parse_string(line)

		if PATH not in parsed_line or DATA not in parsed_line:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [PATH, DATA])
			continue

		var node_path = parsed_line[PATH]
		if not has_node(node_path):
			print("ERROR: Node at path '%s' could not be found, skipping" % node_path)
			continue

		var node = get_node(node_path)
		if not node or not node.has_method(LOAD):
			print("ERROR: Node '%s' is null or doesnt have a %s() function, skipping" % [parsed_line[PATH], LOAD])
			continue

		# call load function
		var data = parsed_line[DATA]
		node.call(LOAD, data)
	return metadata_last_loaded


func load_settings_data():
	if !has_settings_data():
		return

	var config = ConfigFile.new()
	config.load(get_settings_file())

	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)
	for node in settings_nodes:
		if !node.has_method(SAVE) or !node.has_method(LOAD): # object doesnt have save() func
			print("Node '%s' doesnt have a %s() or a %s() function/s" % [node.name, SAVE, LOAD])
			continue

		var data_to_send = {}
		var data: Dictionary = node.call(SAVE)
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION

		data.erase(SECTION)  # don't need it anymore
		if not config.has_section(section):
			print("No section '%s' exists in current setting, skipping node '%s'" % [section, node])
			continue

		for key in data.keys():
			if not config.has_section_key(section, key):
				print("No key '%s' in section '%s' present in current settings" % [key, section])
				continue
			data_to_send[key] = config.get_value(section, key)
		node.call(LOAD, data_to_send)


## --------------
##    TESTING
## --------------

var use_test_file: bool = false
const TEST_SAVE_FILE = "res://tests/save_data_test.save"
const TEST_SETTINGS_FILE = "res://tests/settings_test.cfg"

func setup_test_environ():
	use_test_file = true
	
	# clear potentially set values
	metadata_last_loaded.clear()
