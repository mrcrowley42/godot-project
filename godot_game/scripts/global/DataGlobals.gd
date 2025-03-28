extends Node

signal baby_discovered(uid)
signal creature_discovered(uid)

const SAVE_AS_BINARY = true  ## this does nothing atm

## node save UIDs (DO NOT CHANGE THESE! but you can add new ones if u want)
const SAVE_CREATURE_UID = 0
const SAVE_ACCESSORY_MANAGER_UID = 1
const SAVE_CONSUMABLES_MANAGER_UID = 2

## key: save_uid, value: node
var save_uid_node_atlas = {}

## global metadata items
const VERSION_GLOBAL = "version"
const BUILD_GLOBAL = "build"
const LAST_SAVED_GLOBAL = "last_saved_global"
const CURRENT_CREATURE = "current_creature_id"
const PENDING_EGGS = "pending_eggs"
const HATCHED_EGGS = "hatched_eggs"
const DISCOVERED_BABIES = "discovered_babies"
const DISCOVERED_CREATURES = "discovered_creatures"
const HOLIDAY_MODE = "holiday_mode"
const UNLOCKED_COSMETICS = "unlocked_cosmetics"
const UNLOCKED_FACTS = "unlocked_facts"
const UNLOCKED_THEMES = "unlocked_themes"
const UNLOCKED_ACHIEVEMENTS = "unlocked_achievements"
const ACHIEVEMENT_PROGRESS = "achievement_progress"
const MINIGAME_DATA = "minigame_data"
const ID_INCREMENTAL = "id_incremental"

## creature-relative metadata items
const CREATURE_ID = "creature_id"
const CREATURE_EGG_UID = "creature_egg_uid"
const CREATURE_BABY_UID = "creature_baby_uid"
const CREATURE_TYPE_UID = "creature_type_uid"
const CREATURE_NAME = "creature_name"
const CREATURE_PARENT_ID = "creature_parent_id"
const CREATURE_INITIAL_EGG_TIME = "creature_initial_egg_time"
const CREATURE_EGG_TIME_REMAINING = "creature_egg_time_remaining"
const CREATURE_LIFE_STAGE = "creature_life_stage"
const CREATURE_INITIAL_LIFE_STAGE = "creature_initial_life_stage"
const CREATURE_HATCH_TIME = "creature_hatch_time"
const CREATURE_LAST_SAVED = "creature_last_saved"
const CREATURE_IS_DEAD = "creature_is_dead"
const CREATURE_IS_INDEPENDENT = "creature_is_independent"

## other
const SECTION = "section"
const SAVE_UID = "save_uid"
const GET_SAVE_UID = "get_save_uid"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"

## actions
const ACTION_SET = 0
const ACTION_ADD = 1
const ACTION_APPEND = 2

const AUTOSAVE_SECONDS = 60

## (private) storage of the metadata that was last loaded from the save file
var _current_global_metadata: Dictionary = {}
var _should_save_global_metadata: bool = false

var _every_creature_node_data: Dictionary = {}  # key: id, value: node data list
var _every_creature_metadata: Dictionary = {}  # key: id, value: metadata
var _should_save_creature_metadata: bool = false
var _should_save_creature_metadata_creature_override: int = -1

var settings_data_last_loaded: Dictionary = {"load_the_settings_first_idiot": "bruh"}

func get_save_data_file():
	return Testing.TEST_SAVE_FILE if Testing.is_test_environ else Globals.SAVE_DATA_FILE

func get_settings_file():
	return Testing.TEST_SETTINGS_FILE if Testing.is_test_environ else Globals.SAVE_SETTINGS_FILE

## has any save data incliding global metadata in the file
func has_save_data() -> bool:
	if FileAccess.file_exists(get_save_data_file()):
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		return save_file.get_length() > 0
	return false

func has_settings_data() -> bool:
	return FileAccess.file_exists(get_settings_file())

## does save file only contain metadata (only 1 line exists)
func has_only_global_metadata() -> bool:
	if has_save_data():
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		save_file.get_line()
		return len(save_file.get_line()) == 0  # second line is empty
	return false

## if there is only metadata and no node data for the creature
func has_only_creature_metadata(creature_id_override: int = -1):
	return len(DataGlobals.get_creature_node_data_dc(creature_id_override)) == 0

func get_num_of_creatures():
	return len(get_all_creature_ids())

## get value from last loaded (or the default if it doesn't exist in global metadata)
func get_global_metadata_value(metadata_key: String):
	var value = get_default_global_metadata()[metadata_key]
	if _current_global_metadata.has(metadata_key):
		value = _current_global_metadata[metadata_key]
	if value == null:
		printerr("Replacing <null> value with empty string. Please don't use <null> in save data")
		value = ""
	return value

func get_creature_metadata_value(metadata_key: String, creature_id_override: int = -1):
	var value = get_default_creature_metadata()[metadata_key]
	var creature_id = get_creature_id(creature_id_override)
	if creature_id != -1:
		if _every_creature_metadata.has(creature_id) and _every_creature_metadata[creature_id].has(metadata_key):
			value = _every_creature_metadata[creature_id][metadata_key]
	if value == null:
		printerr("Replacing <null> value with empty string. Please don't use <null> in save data")
		value = ""
	return value

func get_default_global_metadata() -> Dictionary:
	## IMPORTANT: dont use null values, only use empty strings
	return {
		VERSION_GLOBAL: Globals.VERSION,
		BUILD_GLOBAL: Globals.BUILD,
		LAST_SAVED_GLOBAL: Time.get_unix_time_from_system(),
		CURRENT_CREATURE: "-1",
		PENDING_EGGS: [],
		HATCHED_EGGS: [],
		DISCOVERED_BABIES: {},
		DISCOVERED_CREATURES: {},
		HOLIDAY_MODE: false,
		UNLOCKED_COSMETICS: [],
		UNLOCKED_FACTS: [],
		UNLOCKED_THEMES: [],
		UNLOCKED_ACHIEVEMENTS: [],
		ACHIEVEMENT_PROGRESS: {},
		MINIGAME_DATA: {},
		ID_INCREMENTAL: "0"
	}

func get_default_creature_metadata() -> Dictionary:
	## IMPORTANT: dont use null values, only use empty strings
	return {
		CREATURE_ID: -1,
		CREATURE_EGG_UID: "",
		CREATURE_BABY_UID: "",
		CREATURE_TYPE_UID: "",
		CREATURE_NAME: "",
		CREATURE_PARENT_ID: "-1",
		CREATURE_INITIAL_EGG_TIME: 0,
		CREATURE_EGG_TIME_REMAINING: 0,
		CREATURE_LIFE_STAGE: 0,
		CREATURE_INITIAL_LIFE_STAGE: 0,
		CREATURE_HATCH_TIME: -1,
		CREATURE_LAST_SAVED: -1,
		CREATURE_IS_DEAD: false,
		CREATURE_IS_INDEPENDENT: false
	}

func get_creature_id(creature_id_override: int = -1) -> int:
	return creature_id_override if creature_id_override != -1 else int(get_global_metadata_value(CURRENT_CREATURE))

func does_creature_exist(creature_id: int) -> bool:
	return creature_id in _every_creature_metadata.keys()

func get_all_creature_ids() -> Array:
	return _every_creature_metadata.keys()

## deepcopy of the metadata last loaded
func get_global_metadata_dc() -> Dictionary:
	return _current_global_metadata.duplicate(true)

func get_creature_metadata_dc(creature_id_override: int = -1):
	return _every_creature_metadata[get_creature_id(creature_id_override)].duplicate(true)

func get_creature_node_data_dc(creature_id_override: int = -1):
	return _every_creature_node_data[get_creature_id(creature_id_override)].duplicate(true)


## --------------
##    SAVING
## --------------

func _update_val(global: bool, key, value, creature_id_override: int = -1):
	if global:
		_current_global_metadata[key] = value
		_should_save_global_metadata = true
	else:
		_every_creature_metadata[get_creature_id(creature_id_override)][key] = value
		_should_save_creature_metadata_creature_override = creature_id_override
		_should_save_creature_metadata = true

## set / override a value in the metadata
func set_metadata_value(global: bool, metadata_key: String, value, creature_id_override: int = -1):
	if is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT):
		value = str(value)
	_update_val(global, metadata_key, value, creature_id_override)

## add to a value in the metadata
func add_to_metadata_value(global: bool, metadata_key: String, value, convert_to_num: bool = true, creature_id_override: int = -1):
	var new_val = get_global_metadata_value(metadata_key) if global else get_creature_metadata_value(metadata_key, creature_id_override)
	assert(is_instance_of(new_val, TYPE_INT) or is_instance_of(new_val, TYPE_FLOAT) or is_instance_of(new_val, TYPE_STRING))
	assert(is_instance_of(value, TYPE_INT) or is_instance_of(value, TYPE_FLOAT) or is_instance_of(value, TYPE_STRING))
	
	# convert from string to float or int
	if convert_to_num and is_instance_of(new_val, TYPE_STRING):
		@warning_ignore("incompatible_ternary")  # bruh i know
		new_val = float(new_val) if new_val.contains(".") else int(new_val)
	
	# perform operation
	new_val += value
	if convert_to_num:
		new_val = str(new_val)  # back to a string
	_update_val(global, metadata_key, new_val, creature_id_override)

## append to a (list) value in the metadata
func append_to_metadata_value(global: bool, metadata_key: String, value, creature_id_override: int = -1):
	var new_val = get_global_metadata_value(metadata_key) if global else get_creature_metadata_value(metadata_key, creature_id_override)
	assert(is_instance_of(new_val, TYPE_ARRAY))
	new_val.append(value)
	_update_val(global, metadata_key, new_val, creature_id_override)

## modify a dict in the metadata, action: 0=set, 1=add, 2=append
## paths contain the keys to be used to navigate the dictionary value at metadata_key in the metadata
func modify_metadata_value(global: bool, metadata_key: String, paths: Array, action: int, value, creature_id_override: int = -1):
	assert(len(paths) != 0, "just use set_metadata_value() lmao")
	var creature_id = get_creature_id(creature_id_override)
	if global and not _current_global_metadata.has(metadata_key):
		_current_global_metadata[metadata_key] = get_global_metadata_value(metadata_key)
	elif not global and not _every_creature_metadata[creature_id].has(metadata_key):
		_every_creature_metadata[creature_id][metadata_key] = get_creature_metadata_value(metadata_key, creature_id_override)
	
	var ptr = _current_global_metadata[metadata_key] if global else _every_creature_metadata[creature_id][metadata_key]
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
		printerr("Invalid action '%s' when attempting to modify metadata" % action)
	
	_should_save_global_metadata = _should_save_global_metadata or global
	_should_save_creature_metadata = _should_save_creature_metadata or not global
	if _should_save_creature_metadata:
		_should_save_creature_metadata_creature_override = creature_id_override

## takes into account the metadata to override and to add
func generate_global_metadata_to_save() -> Dictionary:
	var all_metadata: Dictionary = get_default_global_metadata()
	for key in all_metadata.keys():
		all_metadata[key] = get_global_metadata_value(key)
	
	# update some values
	all_metadata[VERSION_GLOBAL] = Globals.VERSION
	all_metadata[BUILD_GLOBAL] = Globals.BUILD
	all_metadata[LAST_SAVED_GLOBAL] = Time.get_unix_time_from_system()
	return all_metadata

func generate_creature_metadata_to_save(creature_id_override: int = -1) -> Dictionary:
	var all_metadata: Dictionary = get_default_creature_metadata()
	var creature_id = get_creature_id(creature_id_override)
	for key in all_metadata.keys():
		all_metadata[key] = get_creature_metadata_value(key, creature_id)
	
	# update some values
	if creature_id_override > -1:
		all_metadata[CREATURE_ID] = creature_id_override
	all_metadata[CREATURE_LAST_SAVED] = Time.get_unix_time_from_system()
	return all_metadata

# save file structure:
# line 1  = global_metadata
# line 2+ = [creature_metadata, node_data, node_data, node_data, ...]  (each creature is assigned its own line)
func save_data(creature_id_override: int = -1):
	_should_save_global_metadata = false
	_should_save_creature_metadata = false
	creature_id_override = creature_id_override if creature_id_override > -1 else _should_save_creature_metadata_creature_override
	_should_save_creature_metadata_creature_override = -1
	
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var all_data = [generate_global_metadata_to_save()]  # metadata is first
	_current_global_metadata = all_data[0]
	var creature_id_to_save = get_creature_id(creature_id_override)
	
	# save every creature data & update current creature node data
	for creature_id in _every_creature_metadata.keys():
		var creature_data: Array = [_every_creature_metadata[creature_id]]  # creature metadata first
		var creature_node_data: Array = [_every_creature_node_data[creature_id]]
		
		# update only the creature to save
		if int(creature_id) == creature_id_to_save:
			creature_data = [generate_creature_metadata_to_save(int(creature_id))]  # creature metadata first
			creature_node_data = []
			
			for node in save_nodes:
				if !Globals.has_function(node, SAVE) or !Globals.has_function(node, GET_SAVE_UID):
					continue

				var node_data = {
					SAVE_UID: node.call(GET_SAVE_UID),
					DATA: node.call(SAVE)
				}
				creature_node_data.append(node_data)  # append new node data
		creature_data.append_array(creature_node_data)
		all_data.append(JSON.stringify(creature_data))
	save_file.store_string("\n".join(all_data))
	print("all data saved to file (updated creature '%s')" % creature_id_to_save)

## changes only the first line (the metadata line) in save file, everything else remains unchanged
## CAUTION: DO NOT USE new_metadata_override WITHOUT CARE!!!
func save_only_global_metadata(new_metadata_override = null):
	_should_save_global_metadata = false
	var file_existed = has_save_data()
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	if file_existed: save_file.get_line()  # remove old metadata

	# replace existing metadata with new
	var new_metadata = generate_global_metadata_to_save() if new_metadata_override == null else new_metadata_override
	_current_global_metadata = new_metadata

	var all_lines = [new_metadata]
	if file_existed:  # get the rest of the file
		while save_file.get_position() < save_file.get_length():
			all_lines.append(save_file.get_line())

	save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	save_file.store_string("\n".join(all_lines))
	print("global metadata saved to file")

## saves only the creature's updated metadata, its node data is not updated
func save_only_creature_metadata(creature_id_override: int = -1):
	_should_save_creature_metadata = false
	creature_id_override = creature_id_override if creature_id_override > -1 else _should_save_creature_metadata_creature_override
	_should_save_creature_metadata_creature_override = -1
	
	if not has_save_data():
		printerr("you idiot, save some dam metadata first >:( , aborting")
		return
	
	var creature_id_to_save = get_creature_id(creature_id_override)
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	var global_metadata = save_file.get_line()
	var all_lines = [global_metadata]
	
	while save_file.get_position() < save_file.get_length():
		var line = save_file.get_line()
		var parsed_line: Array = JSON.parse_string(line)
		var creature_metadata = parsed_line.pop_front()

		if creature_metadata[CREATURE_ID] == creature_id_to_save:
			var new_metadata = generate_creature_metadata_to_save(creature_id_to_save)
			if len(parsed_line) > 0 and is_instance_of(parsed_line[0], TYPE_ARRAY):  # idk why but it puts itself inside another array sometimes
				parsed_line = parsed_line[0]
			line = [new_metadata, parsed_line]
			_every_creature_metadata[creature_id_to_save] = new_metadata
		all_lines.append(line)
	
	save_file = FileAccess.open(get_save_data_file(), FileAccess.WRITE)
	save_file.store_string("\n".join(all_lines))
	print("Creature '%s' metadata saved (did not update node data)" % creature_id_to_save)

func create_new_egg_creature(egg: EggEntry, parent_id):
	var egg_type_uid = Helpers.uid_str(egg)
	var initial_creature_name = egg.name
	var creature_id: String = get_global_metadata_value(ID_INCREMENTAL)
	add_to_metadata_value(true, ID_INCREMENTAL, 1)
	
	var new_creature_metadata = generate_creature_metadata_to_save(int(creature_id))
	new_creature_metadata[CREATURE_EGG_UID] = egg_type_uid
	new_creature_metadata[CREATURE_PARENT_ID] = str(parent_id)
	new_creature_metadata[CREATURE_NAME] = initial_creature_name
	var init_egg_time = randi_range(9_000, 11_000)  # in seconds
	new_creature_metadata[CREATURE_INITIAL_EGG_TIME] = init_egg_time
	new_creature_metadata[CREATURE_EGG_TIME_REMAINING] = init_egg_time
	var init_life_stage = Creature.LifeStage.EGG
	new_creature_metadata[CREATURE_LIFE_STAGE] = init_life_stage
	new_creature_metadata[CREATURE_INITIAL_LIFE_STAGE] = init_life_stage
	
	DataGlobals.set_metadata_value(true, DataGlobals.CURRENT_CREATURE, creature_id)
	
	_every_creature_metadata[int(creature_id)] = new_creature_metadata
	_every_creature_node_data[int(creature_id)] = []
	print("new egg creature '%s' created (type uid %s), did not save." % [creature_id, egg_type_uid])
	return int(creature_id)

## create a new creature in memory, does not save to file, call save_data yourself (returns its new id)
func create_new_creature(egg: EggEntry, baby_type: CreatureBaby) -> int:
	var egg_type_uid = Helpers.uid_str(egg)
	var baby_type_uid = Helpers.uid_str(baby_type)
	var initial_creature_name = baby_type.name
	var creature_id: String = get_global_metadata_value(ID_INCREMENTAL)
	add_to_metadata_value(true, ID_INCREMENTAL, 1)
	
	var creature_choice = _choose_creature_baby_grows_into(baby_type)
	
	var new_creature_metadata = generate_creature_metadata_to_save(int(creature_id))
	new_creature_metadata[CREATURE_EGG_UID] = egg_type_uid
	new_creature_metadata[CREATURE_BABY_UID] = baby_type_uid
	new_creature_metadata[CREATURE_TYPE_UID] = creature_choice
	new_creature_metadata[CREATURE_HATCH_TIME] = Time.get_unix_time_from_system()
	new_creature_metadata[CREATURE_NAME] = initial_creature_name
	var init_life_stage = Creature.LifeStage.BABY  # skip egg stage for first ever creature
	new_creature_metadata[CREATURE_LIFE_STAGE] = init_life_stage
	new_creature_metadata[CREATURE_INITIAL_LIFE_STAGE] = init_life_stage
	
	set_metadata_value(true, DataGlobals.CURRENT_CREATURE, creature_id)
	
	_every_creature_metadata[int(creature_id)] = new_creature_metadata
	_every_creature_node_data[int(creature_id)] = []
	print("new creature '%s' created (baby uid %s, type uid %s), did not save." % [creature_id, baby_type_uid, creature_choice])
	return int(creature_id)

## hatches a creature in memory, updating the creature metadata for the given creature id
func hatch_creature(creature_id: int, baby_type: CreatureBaby):
	var baby_type_uid = Helpers.uid_str(baby_type)
	var initial_creature_name = baby_type.name
	var creature_choice = _choose_creature_baby_grows_into(baby_type)
	
	set_metadata_value(false, CREATURE_BABY_UID, baby_type_uid, creature_id)
	set_metadata_value(false, CREATURE_TYPE_UID, creature_choice, creature_id)
	set_metadata_value(false, CREATURE_HATCH_TIME, Time.get_unix_time_from_system(), creature_id)
	set_metadata_value(false, CREATURE_NAME, initial_creature_name, creature_id)
	set_metadata_value(false, CREATURE_LIFE_STAGE, Creature.LifeStage.BABY, creature_id)
	
	set_metadata_value(true, DataGlobals.CURRENT_CREATURE, creature_id)
	Globals.delete_creature_icon(creature_id)

## choose a creature type uid that given baby should grow into
func _choose_creature_baby_grows_into(baby_type: CreatureBaby) -> String:
	var discovered_creatures: Array = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES).keys()
	var choices = [Helpers.uid_str(baby_type.grows_into_a), Helpers.uid_str(baby_type.grows_into_b)]
	var final_choice = [0, 1].pick_random()
	
	# if already discovered chosen creature and not discovered other creaturee, use other creature
	if discovered_creatures.has(choices[final_choice]) and not discovered_creatures.has(choices[1-final_choice]):
		final_choice = 1 - final_choice
	return choices[final_choice]

func save_settings_data():
	var config = ConfigFile.new()
	config.load(get_settings_file())  # so we dont just purge everything
	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)

	for node in settings_nodes:
		if !Globals.has_function(node, SAVE):
			continue

		var data = node.call(SAVE)
		if typeof(data) != TYPE_DICTIONARY:
			printerr("Node '%s' save data is not of type dictionary (data: '%s'). Skipping" % [node.name, data])
			return
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION

		for key in data.keys():
			if key != SECTION:
				config.set_value(section, key, data[key])
	config.save(get_settings_file())
	print("settings data saved to file")

## save everything every n seconds
func setup_auto_save(timer_parent):
	var timer: Timer = Timer.new()
	timer.name = "autosave_timer"
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = AUTOSAVE_SECONDS
	timer.timeout.connect(save_data)
	timer_parent.add_child(timer)
	print("--- Autosave started for every %s seconds ---" % AUTOSAVE_SECONDS)

## --------------
##    LOADING
## --------------

# build node atlas with all nodes in SAVE_DATA_GROUP
func build_save_uid_node_atlas():
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	for node in save_nodes:
		if !Globals.has_function(node, GET_SAVE_UID):
			return
		save_uid_node_atlas[node.call(GET_SAVE_UID)] = node
	print("node uid atlas built with %s nodes" % len(save_nodes))

## loads only the metadata line from save (if it exists)
func load_global_metadata() -> Dictionary:
	if _should_save_global_metadata:
		printerr("Cannot load global metadata from file as there are unsaved changes to the metadata")
		return get_global_metadata_dc()
	
	if has_save_data():
		var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
		_current_global_metadata = JSON.parse_string(save_file.get_line())
	print("global metadata has been loaded from file")
	return get_global_metadata_dc()

## loads creature metadata and node data
func load_creature_data(creature_id_override: int = -1):
	if _should_save_creature_metadata:
		printerr("Cannot load creature metadata from file as there are unsaved changes to the metadata")
		return
	
	var creature_id = get_creature_id(creature_id_override)
	if creature_id < 0:
		printerr("current creature is not set")
		return
	
	## put default metadata and an empty node data list
	if not _every_creature_metadata.has(creature_id):
		printerr("no data for creature %s exists, using default data" % creature_id)
		_every_creature_metadata[creature_id] = generate_creature_metadata_to_save(creature_id)
		_every_creature_node_data[creature_id] = []
	
	## load the node data
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var node_data_skipped = []
	for node_data in _every_creature_node_data[creature_id]:
		if SAVE_UID not in node_data or DATA not in node_data:
			printerr("'%s' or '%s' value in save data is missing! skipping" % [SAVE_UID, DATA])
			continue

		var data = node_data[DATA]
		var save_uid: int = int(node_data[SAVE_UID])
		if !save_uid_node_atlas.has(save_uid):
			printerr("Node with save uid of '%s' could not be found, skipping" % save_uid)
			node_data_skipped.append(data)
			continue

		var node: Node = save_uid_node_atlas[save_uid]
		if node not in save_nodes:
			printerr("Node '%s' is not in '%s' group, skipping" % [node, Globals.SAVE_DATA_GROUP])
			node_data_skipped.append(data)
			continue

		save_nodes.erase(node)
		if not Globals.has_function(node, LOAD):
			node_data_skipped.append(data)
			continue
		node.call(LOAD, data)
	
	## check for nodes that missed being loaded
	# attempts to call load data with data returned from the save function
	var has_no_node_data = len(_every_creature_node_data[creature_id]) == 0
	if not has_no_node_data and len(save_nodes) > 0:
		printerr("%s Nodes for creature '%s' were not loaded: '%s'.\nAttempting to fix..." % [len(save_nodes), creature_id, save_nodes])
		
		for node in save_nodes:
			if not Globals.has_function(node, LOAD) or not Globals.has_function(node, SAVE):
				continue
			save_nodes.erase(node)
			node.call(LOAD, node.call(SAVE))  # load the nodes default save data
	
	## final error message
	if not has_no_node_data and len(save_nodes) > 0:
		printerr("--- VERY BIG WARNING ---\n%s Node data for creature '%s' is MISSING from the save file and COULD NOT be loaded:\n%s\n--- VERY BIG WARNING ---" % [len(save_nodes), creature_id, save_nodes])
	
	if len(node_data_skipped) > 0:
		printerr("Some data for creature '%s' was not loaded! %s nodes/s were missed" % [creature_id, len(node_data_skipped)])
	print("Creature '%s' metadata & node data has been loaded from file" % creature_id)

## loads data, and passes it to saved nodes. returns metadata
func load_data() -> Dictionary:
	build_save_uid_node_atlas()
	Helpers.setup_uid_cache()
	
	if not SAVE_AS_BINARY:
		printerr("WARNING: Save data is being not saved in binary format!")

	if _should_save_global_metadata:
		printerr("Cannot load global metadata from file as there are unsaved changes to the metadata")
		return get_global_metadata_dc()

	if !has_save_data():
		return get_global_metadata_dc()

	# attempt to load
	var save_file = FileAccess.open(get_save_data_file(), FileAccess.READ)
	_current_global_metadata = JSON.parse_string(save_file.get_line())
	
	# every creature line
	while save_file.get_position() < save_file.get_length():
		var line = save_file.get_line()
		var parsed_line: Array = JSON.parse_string(line)
		var creature_metadata = parsed_line.pop_front()
		
		var creature_id: int = int(creature_metadata[CREATURE_ID])  ## this type assignment is VERY IMPORTANT!!!
		_every_creature_metadata[creature_id] = creature_metadata
		_every_creature_node_data[creature_id] = parsed_line[0] if len(parsed_line) == 1 else []  # expecting a list
	print("all save data has been loaded from file")
	return get_global_metadata_dc()


func load_settings_data():
	if !has_settings_data():
		return

	var config = ConfigFile.new()
	config.load(get_settings_file())

	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)
	for node in settings_nodes:
		if !Globals.has_function(node, SAVE) or !Globals.has_function(node, LOAD):
			continue

		var data_to_send = {}
		var data: Dictionary = node.call(SAVE)
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION

		data.erase(SECTION)  # don't need it anymore
		if not config.has_section(section):
			printerr("No section '%s' exists in current setting, skipping node '%s'" % [section, node])
			continue

		for key in data.keys():
			if not config.has_section_key(section, key):
				printerr("No key '%s' in section '%s' present in current settings" % [key, section])
				continue
			data_to_send[key] = config.get_value(section, key)
		node.call(LOAD, data_to_send)
	
	## generate dict for any external referencing
	settings_data_last_loaded = {}
	for section in config.get_sections():
		settings_data_last_loaded[section] = {}
		for key in config.get_section_keys(section):
			settings_data_last_loaded[section][key] = config.get_value(section, key)
	print("settings data loaded from file")


## ------------
##    OTHER
## ------------

func add_to_eggs_hatched(egg: EggEntry):
	var uid = Helpers.uid_str(egg)
	if not get_global_metadata_value(HATCHED_EGGS).has(uid):
		append_to_metadata_value(true, HATCHED_EGGS, uid)

func add_to_babies_discovered(creature_baby: CreatureBaby):
	var uid = Helpers.uid_str(creature_baby)
	if get_global_metadata_value(DISCOVERED_BABIES).has(uid):
		modify_metadata_value(true, DISCOVERED_BABIES, [uid, "num_times_found"], ACTION_ADD, 1)
		print("hatched another '%s' baby" % uid)
	else:
		var dict = {
			"uid": uid,
			"num_times_found": 1
		}
		modify_metadata_value(true, DISCOVERED_BABIES, [uid], ACTION_SET, dict)
		baby_discovered.emit(uid)
		print("new baby discovered '%s'" % uid)

## add a newly discovered creature, or add 1 to "times_hatched" if already discovered
func add_to_creatures_discovered(creature_type: CreatureType, _uid=null):
	var uid = Helpers.uid_str(creature_type) if creature_type else _uid
	if get_global_metadata_value(DISCOVERED_CREATURES).has(uid):
		# add 1 to times grown
		modify_metadata_value(true, DISCOVERED_CREATURES, [uid, "num_times_found"], ACTION_ADD, 1)
		print("grown another '%s' creature" % uid)
	else:
		# add new creature discovered
		var dict = {
			"uid": uid,
			"max_stage_reached": 1,
			"num_times_found": 1
		}
		modify_metadata_value(true, DISCOVERED_CREATURES, [uid], ACTION_SET, dict)
		creature_discovered.emit(uid)
		print("new creature discovered '%s'" % uid)

func set_new_highest_life_stage(uid: String, life_stage: int):
	# if another creature grown from a baby or never grown before
	if life_stage == 2 or not get_global_metadata_value(DISCOVERED_CREATURES).has(uid):
		add_to_creatures_discovered(null, uid)
	
	var current_highest = get_global_metadata_value(DISCOVERED_CREATURES)[uid]["max_stage_reached"]
	modify_metadata_value(true, DISCOVERED_CREATURES, [uid, "max_stage_reached"], ACTION_SET, max(current_highest, life_stage))

func is_every_creature_dead() -> bool:
	if DataGlobals.has_only_global_metadata() or not DataGlobals.has_save_data():
		return true
	
	var is_dead = true
	for creature_id in _every_creature_metadata.keys():
		if is_dead:
			is_dead = get_creature_metadata_value(CREATURE_IS_DEAD, creature_id)
	return is_dead

func add_pending_egg(egg: EggEntry, parent_id):
	var data = {
		'egg_uid': Helpers.uid_str(egg),
		'parent_id': parent_id
	}
	append_to_metadata_value(true, DataGlobals.PENDING_EGGS, data)

func find_parent_name(parent_id) -> String:
	return DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME, int(parent_id)) if DataGlobals.does_creature_exist(int(parent_id)) else 'Unknown'

func _process(_delta: float) -> void:
	# save metadata here so the file only needs to be written to once in a frame
	# no matter the number of metadata changes that occurred this frame
	if _should_save_global_metadata:
		save_only_global_metadata()
	if _should_save_creature_metadata:
		save_only_creature_metadata()
