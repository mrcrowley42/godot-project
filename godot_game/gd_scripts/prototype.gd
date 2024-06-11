extends Node


const SAVE_DATA_GROUP = "save_data"
const SAVE_DATA_FILE = "res://save_data.save"

const SAVE_SETTINGS_GROUP = "settings_data"
const SAVE_SETTINGS_FILE = "res://settings.conf"

const PATH = "path"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"


func _ready():
	#load_all_data(SAVE_DATA_FILE)
	#load_all_data(SAVE_SETTINGS_FILE)
	pass


func save_all_data():
	var save_file = FileAccess.open(SAVE_DATA_FILE, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(SAVE_DATA_GROUP)
	
	var all_data = []
	
	# save metadata
	var metadata = {"time_saved": Time.get_unix_time_from_system()}
	all_data.append(metadata)
	
	# save node data
	for node in save_nodes:
		if !node.has_method(SAVE):  # object doesnt have save() func
			print("Node '%s' doesnt have a %s() function" % [node.name, SAVE])
			continue
		
		var node_data = {
			PATH: node.get_path(),
			DATA: node.call(SAVE)
		}
		all_data.append(JSON.stringify(node_data))
	
	var binary_data: PackedByteArray = var_to_bytes(all_data)
	save_file.store_var(binary_data)


func load_all_data(file):
	# no save data, cancel
	if not FileAccess.file_exists(file):
		print("no file " + file)
		return
	
	var save_file = FileAccess.open(file, FileAccess.READ)
	var data_lines: Array = bytes_to_var(save_file.get_var())
	var metadata_line = data_lines.pop_at(0)
	
	for line in data_lines:
		var parsed_line = JSON.parse_string(line)
		
		# check data has necessary values
		if PATH not in parsed_line or DATA not in parsed_line:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [PATH, DATA])
			continue
		
		# get data
		var node = get_node(parsed_line[PATH])
		var data = parsed_line[DATA]
		
		# pass data to node for it to load
		if !node.has_method(LOAD):
			print("ERROR: Node '%s' doesnt have a %s() function" % [node.name, LOAD])
			continue
		node.call(LOAD, data)


func _input(event):
	# close when `esc` key is pressed
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
