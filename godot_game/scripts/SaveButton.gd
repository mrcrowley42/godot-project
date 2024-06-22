extends Button

const SAVE = "save"


func _pressed():
	save_all_data()

func save_all_data():
	var save_file = FileAccess.open(Globals.SAVE_FILE, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_GROUP)
	
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
			Globals.PATH: node.get_path(),
			Globals.DATA: node.call(SAVE)
		}
		all_data.append(JSON.stringify(node_data))
	
	var binary_data: PackedByteArray = var_to_bytes(all_data)
	save_file.store_var(binary_data)
	
	print("Saved data!")
