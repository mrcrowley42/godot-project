extends Node


const SAVE_DATA_GROUP = "save_data"
const SAVE_DATA_FILE = "res://save_data.save"

const SAVE_SETTINGS_GROUP = "settings_data"
const SAVE_SETTINGS_FILE = "res://settings.txt"

const PATH = "path"
const DATA = "data"
const SAVE = "save"
const LOAD = "load"


func _ready():
	load_data(SAVE_DATA_FILE, true, true)
	load_data(SAVE_SETTINGS_FILE)


func _on_save_pressed():
	save_data(SAVE_DATA_FILE, SAVE_DATA_GROUP, true, true)
	save_data(SAVE_SETTINGS_FILE, SAVE_SETTINGS_GROUP)


func save_data(file, group, encode_binary=false, save_metadata=false):
	var save_file = FileAccess.open(file, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(group)
	var all_data = []
	
	if save_metadata:
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
	
	if encode_binary:
		var bytes_array: PackedByteArray = var_to_bytes(all_data)
		save_file.store_var(bytes_array)
	else:
		for l in all_data:
			save_file.store_line(l)


func load_data(file, binary_encoded=false, has_metadata=false):
	if not FileAccess.file_exists(file):
		return
	
	var save_file = FileAccess.open(file, FileAccess.READ)
	var metadata = ""
	var file_lines: Array

	if binary_encoded:
		file_lines = bytes_to_var(save_file.get_var())
	else:
		while save_file.get_position() < save_file.get_length():
			file_lines.append(save_file.get_line())
	
	if has_metadata:
		metadata = file_lines.pop_at(0)
	
	for line in file_lines:
		var parsed_line = JSON.parse_string(line)
		
		# check data has necessary values
		if PATH not in parsed_line or DATA not in parsed_line:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [PATH, DATA])
			continue
		
		# get data
		var node = get_node(parsed_line[PATH])
		
		if node and node.has_method(LOAD):
			var data = parsed_line[DATA]
			node.call(LOAD, data)
		else:
			print("ERROR: Node '%s' is null or doesnt have a %s() function" % [node.name, LOAD])


func _input(event):
	# close when `esc` key is pressed
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
