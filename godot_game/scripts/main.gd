extends Node

const SECTION = "section"
const PATH = "path"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"

@export var debug_mode: bool
@export var unlock_fps: bool = false

var last_opened: float
@onready var launch_time: float = Time.get_unix_time_from_system()
@onready var stat_man: StatusManager = %StatusManager
#@onready var launch_date = Time.get_datetime_dict_from_system().day
@onready var minigame_man: MinigameManager = %MinigameManager
@onready var debug_window = $DebugWindow

func _ready():
	if unlock_fps:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) # HUH?
	load_data()
	load_settings_data()
	calc_elapsed_time()
	debug_window.visible = debug_mode
	# Disable the script execution when the panel is disabled/hidden.
	if not debug_mode:
		debug_window.process_mode = Node.PROCESS_MODE_DISABLED

func calc_elapsed_time():
	var elapsed_time = launch_time - last_opened
	# please excuse the bad variable names here, this is only a temp thing anyway.
	var _a = Color(1,0,0)
	var _b = Color(0,1,0)
	var max_time = 600  # in seconds
	var _c = _b.lerp(_a, clampf(elapsed_time/max_time,0,1))
	_c.v = 1.0
	_c = _c.lightened(.25)
	print_rich("[color=%s]%.2f seconds since last played.[/color]" %[_c.to_html() ,elapsed_time])
	print("%.2f days since last played." %[elapsed_time/86400])
	var holiday_status = "were" if stat_man.holiday_mode else "were not"
	print("And you %s on holiday." % [holiday_status])
	#print(launch_date)

func _on_save_pressed():
	%BtnClick.play()
	%SFX.play_sound("correct")
	save_settings_data()

func _notification(noti):
	if noti == NOTIFICATION_WM_CLOSE_REQUEST:
		minigame_man.finalise_save_data()  # call before saving
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
