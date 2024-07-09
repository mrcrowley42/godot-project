extends Node

const SECTION = "section"
const PATH = "path"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"

var last_opened: float

@onready var stat_man: StatusManager = %StatusManager

func _ready():
	load_data()
	load_settings_data()
	
	print("%.2f seconds since last played." %[Time.get_unix_time_from_system() - last_opened])
	var holiday_status = "were" if stat_man.holiday_mode else "were not"
	print("And you %s on holiday." % [holiday_status])
	
func _on_save_pressed():
	%BtnClick.play()
	%SFX.play_sound("correct")
	save_settings_data()

func _notification(noti):
	if noti == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()

func save_data():
	var save_file = FileAccess.open(Globals.SAVE_DATA_FILE, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_DATA_GROUP)
	var all_data = []
	
	var metadata = {"time_saved": Time.get_unix_time_from_system()}
	all_data.append(metadata)
	
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
	
	var bytes_array: PackedByteArray = var_to_bytes(all_data)
	save_file.store_var(bytes_array)

func save_settings_data():
	var config = ConfigFile.new()
	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)
	
	for node in settings_nodes:
		if !node.has_method(SAVE): # object doesnt have save() func
			print("Node '%s' doesnt have a %s() function" % [node.name, SAVE])
			continue
		
		var data = node.call(SAVE)
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION
		
		for key in data.keys():
			if key != SECTION:
				config.set_value(section, key, data[key])
		
		config.save(Globals.SAVE_SETTINGS_FILE)

func load_data():
	if not FileAccess.file_exists(Globals.SAVE_DATA_FILE):
		return
	
	var save_file = FileAccess.open(Globals.SAVE_DATA_FILE, FileAccess.READ)
	var file_lines: Array = bytes_to_var(save_file.get_var())
	last_opened = file_lines.pop_at(0)['time_saved']
	
	for line in file_lines:
		var parsed_line = JSON.parse_string(line)
		
		# check data has necessary values
		if PATH not in parsed_line or DATA not in parsed_line:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [PATH, DATA])
			continue
		
		var node = get_node(parsed_line[PATH])
		if node and node.has_method(LOAD):
			var data = parsed_line[DATA]
			node.call(LOAD, data)
		else:
			print("ERROR: Node '%s' is null or doesnt have a %s() function" % [parsed_line[PATH], LOAD])

func load_settings_data():
	if not FileAccess.file_exists(Globals.SAVE_SETTINGS_FILE):
		return
	
	var config = ConfigFile.new()
	config.load(Globals.SAVE_SETTINGS_FILE)
	
	var settings_nodes = get_tree().get_nodes_in_group(Globals.SAVE_SETTINGS_GROUP)
	
	for node in settings_nodes:
		if !node.has_method(SAVE) or !node.has_method(LOAD): # object doesnt have save() func
			print("Node '%s' doesnt have a %s() or a %s() function/s" % [node.name, SAVE, LOAD])
			continue
		
		var data_to_send = {}
		var data = node.call(SAVE)
		var section = data[SECTION] if data.has(SECTION) else Globals.DEFAULT_SECTION
		
		for key in data.keys():
			if key != SECTION and config.has_section(section) and config.has_section_key(section, key):
				data_to_send[key] = config.get_value(section, key)
		node.call(LOAD, data_to_send)

func _input(event) -> void:
	# close when [param esc key] is pressed
	if event.is_action_pressed("ui_cancel"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
