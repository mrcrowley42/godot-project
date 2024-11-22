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
## metadata to be overriden on next save (override the current metadata for something new)
var metadata_to_override: Dictionary = {}
## metadata to be added to on next save (e.g. to be appended to a list)
var metadata_to_add: Dictionary = {}

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

## takes into account the metadata to override and to add
func generate_metadata_to_save() -> Dictionary:
	var get_if_exists = func(key: String, fallback, check_for_override: bool = false):
		var already_has_key = metadata_to_override.has(key)
		if check_for_override and already_has_key:
			return metadata_to_override[key]  # old value is to be overridden, return new value
		return metadata_last_loaded[key] if already_has_key else fallback

	var get_and_check_for_addition = func(key: String, fallback):
		var val = get_if_exists.call(key, fallback)
		if metadata_to_add.has(key):
			val += metadata_to_add[key]  # generically (and unsafely) add to old value
		return val

	var do_discovered_creatures = func():
		var val: Array = get_if_exists.call(CREATURES_DISCOVERED, [])
		if metadata_to_add.has(CREATURES_DISCOVERED):
			val.append({
				"uid": metadata_to_add[CREATURES_DISCOVERED],
				"highest_stage_reached": 0,
				"times_hatched": 1
			})
		return val

	# give these values the custom function they require
	return {
		LAST_SAVED: Time.get_unix_time_from_system(),
		CURRENT_CREATURE: str(get_if_exists.call(CURRENT_CREATURE, null, true)),
		CREATURES_DISCOVERED: do_discovered_creatures.call(),
		UNLOCKED_COSMETICS: get_and_check_for_addition.call(UNLOCKED_COSMETICS, []),
		UNLOCKED_FACTS: get_and_check_for_addition.call(UNLOCKED_FACTS, []),
		UNLOCKED_THEMES: get_and_check_for_addition.call(UNLOCKED_THEMES, [])
	}

# save file structure:
# line 1  = metadata
# line 2+ = node data  (each node is assigned its own line)
func save_data():
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var all_data = [generate_metadata_to_save()]  # metadata is first
	metadata_to_override.clear()
	metadata_to_add.clear()

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
	metadata_to_override.clear()
	metadata_to_add.clear()

	var all_lines = [new_metadata]
	if file_existed:  # get the reat of the file
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
	metadata_to_add.clear()
	metadata_to_override.clear()
