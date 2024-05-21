extends Button

const LOAD = "load"


func _pressed():
	load_all_data()

func load_all_data():
	# no save data, cancel
	if not FileAccess.file_exists(Globals.SAVE_FILE):
		print("No save data found!")
		return
	
	var save_file = FileAccess.open(Globals.SAVE_FILE, FileAccess.READ)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_GROUP)
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parsed_data = json.parse_string(json_string)
		
		# check data has necessary values
		if Globals.PATH not in parsed_data or Globals.DATA not in parsed_data:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [Globals.PATH, Globals.DATA])
			continue
		
		# get data
		var node = get_node(parsed_data[Globals.PATH])
		var data = parsed_data[Globals.DATA]
		
		# pass data to node for it to load
		if !node.has_method(LOAD):
			print("ERROR: Node '%s' doesnt have a %s() function" % [node.name, LOAD])
			continue
		var node_data = node.call(LOAD, data)
	print("Loaded data!")
