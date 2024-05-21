extends Button

const SAVE = "save"


func _pressed():
	save_all_data()

func save_all_data():
	var save_file = FileAccess.open(Globals.SAVE_FILE, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group(Globals.SAVE_GROUP)
	
	for node in save_nodes:
		# object doesnt have save() func
		if !node.has_method(SAVE):
			print("Node '%s' doesnt have a %s() function" % [node.name, SAVE])
			continue
		
		var node_data = {
			Globals.PATH: node.get_path(),
			Globals.DATA: node.call(SAVE)
		}
		var serialized_data = JSON.stringify(node_data)
		
		save_file.store_line(serialized_data)
	print("Saved data!")
