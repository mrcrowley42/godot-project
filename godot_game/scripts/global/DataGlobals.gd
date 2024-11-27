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

# actions
const ACTION_SET = 0
const ACTION_ADD = 1
const ACTION_APPEND = 2

const AUTOSAVE_SECONDS = 60

## (private) storage of the metadata that was last loaded from the save file
var _current_metadata: Dictionary = {}
var _should_save_metadata: bool = false

func get_save_data_file():
	return Testing.TEST_SAVE_FILE if Testing.is_test_environ else Globals.SAVE_DATA_FILE

func get_settings_file():
	return Testing.TEST_SETTINGS_FILE if Testing.is_test_environ else Globals.SAVE_SETTINGS_FILE

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
		save_file.get_line()
		return len(save_file.get_line()) == 0  # second line is empty
	return false

## get value from last loaded (or the default if it doesn't exist in metadata)
func get_metadata_value(metadata_key: String):
	var value = get_default_metadata()[metadata_key]
	if _current_metadata.has(metadata_key):
		value = _current_metadata[metadata_key]
	return value

func get_default_metadata() -> Dictionary:
	## IMPORTANT: dont use null values, only use empty strings
	return {
		LAST_SAVED: Time.get_unix_time_from_system(),
		CURRENT_CREATURE: "",
		CREATURES_DISCOVERED: {},
		UNLOCKED_COSMETICS: [],
		UNLOCKED_FACTS: [],
		UNLOCKED_THEMES: []
	}

## deepcopy of the metadata last loaded
func get_current_metadata_dc() -> Dictionary:
	return _current_metadata.duplicate(true)

## --------------
##    SAVING
## --------------

## set / override a value in the metadata
func set_metadata_value(metadata_key: String, value):
	if is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT):
		value = str(value)
	
	_current_metadata[metadata_key] = value
	_should_save_metadata = true

## add to a value in the metadata
func add_to_metadata_value(metadata_key: String, value, convert_to_num: bool = true):
	var new_val = get_metadata_value(metadata_key)
	assert(is_instance_of(new_val, TYPE_INT) or is_instance_of(new_val, TYPE_FLOAT) or is_instance_of(new_val, TYPE_STRING))
	assert(is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT) or is_instance_of(value, TYPE_STRING))
	
	# convert from string to float or int
	if convert_to_num and is_instance_of(new_val, TYPE_STRING):
		@warning_ignore("incompatible_ternary")  # bruh i know
		new_val = float(new_val) if new_val.contains(".") else int(new_val)
	
	# add
	new_val += value
	if convert_to_num:
		new_val = str(new_val)  # back to a string
	
	_current_metadata[metadata_key] = new_val
	_should_save_metadata = true

## append to a (list) value in the metadata
func append_to_metadata_value(metadata_key: String, value):
	var new_val = get_metadata_value(metadata_key)
	assert(is_instance_of(new_val, TYPE_ARRAY))
	new_val.append(value)
	
	_current_metadata[metadata_key] = new_val
	_should_save_metadata = true

## modify a dict in the metadata, action: 0=set, 1=add, 2=append
## paths contain the keys to be used to navigate the dictionary value at metadata_key in the metadata
func modify_metadata_value(metadata_key: String, paths: Array, action: int, value):
	assert(len(paths) != 0, "just use set_metadata_value() lmao")
	if not _current_metadata.has(metadata_key):
		_current_metadata[metadata_key] = get_metadata_value(metadata_key)
	
	var ptr = _current_metadata[metadata_key]  # pointer
	var last_key = paths.pop_back()
	for key in paths:
		ptr = ptr[key]
	
	if action == ACTION_SET:
		ptr[last_key] = value
	elif action == ACTION_ADD:
		assert(is_instance_of(ptr[last_key], TYPE_INT) or is_instance_of(ptr[last_key], TYPE_FLOAT) or is_instance_of(ptr[last_key], TYPE_STRING))
		ptr[last_key] += value  # add
	elif action == ACTION_APPEND:
		assert(is_instance_of(ptr[last_key], TYPE_ARRAY))
		ptr[last_key].append(value)  # append
	else:
		print("ERROR: invalid action '%s' when attempting to modify metadata" % action)
	_should_save_metadata = true

## takes into account the metadata to override and to add
func generate_metadata_to_save() -> Dictionary:
	var all_metadata: Dictionary = get_default_metadata()
	
	for key in all_metadata.keys():
		all_metadata[key] = get_metadata_value(key)
	
	all_metadata[LAST_SAVED] = Time.get_unix_time_from_system()
	return all_metadata

# save file structure:
# line 1  = metadata
# line 2+ = node data  (each node is assigned its own line)
func save_data():
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var all_data = [generate_metadata_to_save()]  # metadata is first
	_current_metadata = all_data[0]

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
	_should_save_metadata = false
	var file_existed = has_save_data()
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	if file_existed: save_file.get_line()  # remove old metadata

	# replace existing metadata with new
	var new_metadata = generate_metadata_to_save()
	_current_metadata = new_metadata

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

## save everything every n seconds
func setup_auto_save(timer_parent):
	var timer: Timer = Timer.new()
	timer.name = "autosave_timer"
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = AUTOSAVE_SECONDS
	timer.timeout.connect(save_data)
	timer_parent.add_child(timer)

## --------------
##    LOADING
## --------------

## loads only the metadata line from save (if it exists)
func load_metadata() -> Dictionary:
	if _should_save_metadata:
		printerr("Cannot load as changes to metadata have not been saved")
		return get_current_metadata_dc()
	
	if has_save_data():
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		_current_metadata = JSON.parse_string(save_file.get_line())
	return get_current_metadata_dc()

## loads data, and passes it to saved nodes. returns metadata
func load_data() -> Dictionary:
	if _should_save_metadata:
		printerr("Cannot load as changes to metadata have not been saved")
		return get_current_metadata_dc()
	
	if !has_save_data():
		return get_current_metadata_dc()

	# attempt to load
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	_current_metadata = JSON.parse_string(save_file.get_line())

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
	return get_current_metadata_dc()


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


## ------------
##    OTHER
## ------------

## add a newly discovered creature, or add 1 to "times_hatched" if already discovered
func add_to_creatures_discovered(uid: String):
	if get_metadata_value(CREATURES_DISCOVERED).has(uid):
		# add 1 to times hatched
		modify_metadata_value(CREATURES_DISCOVERED, [uid, "num_times_hatched"], ACTION_ADD, 1)
	else:
		# add new creature discovered
		var dict = {
			"uid": uid,
			"max_stage_reached": 0,
			"num_times_hatched": 1
		}
		modify_metadata_value(CREATURES_DISCOVERED, [uid], ACTION_SET, dict)

func set_new_highest_life_stage(uid: String, life_stage: int):
	var current_highest = get_metadata_value(CREATURES_DISCOVERED)[uid]["max_stage_reached"]
	modify_metadata_value(CREATURES_DISCOVERED, [uid, "max_stage_reached"], ACTION_SET, max(current_highest, life_stage))

func _process(_delta: float) -> void:
	# save metadata here so the file only needs to be written to once in a frame
	# no matter the number of metadata changes that occurred this frame
	if _should_save_metadata:
		save_only_metadata()
