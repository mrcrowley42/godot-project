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
	var data_lines: Array = bytes_to_var(save_file.get_var())
	
	var metadata_line = data_lines.pop_at(0)
	print("metadata: ", metadata_line)
	
	for line in data_lines:
		var parsed_line = JSON.parse_string(line)
		
		# check data has necessary values
		if Globals.PATH not in parsed_line or Globals.DATA not in parsed_line:
			print("ERROR: Missing '%s' or '%s' value for data, skipping" % [Globals.PATH, Globals.DATA])
			continue
		
		# get data
		var node = get_node(parsed_line[Globals.PATH])
		var data = parsed_line[Globals.DATA]
		
		# pass data to node for it to load
		if !node.has_method(LOAD):
			print("ERROR: Node '%s' doesnt have a %s() function" % [node.name, LOAD])
			continue
		node.call(LOAD, data)
	
	print("Loaded data!")
