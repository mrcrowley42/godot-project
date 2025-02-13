extends Button

@onready var name_label = find_child("NameLabel")
@onready var date_label = find_child("DateLabel")
@onready var creature_icon: Button = find_child("CreatureIcon")
var save_file: Dictionary
var parent_menu

func _ready() -> void:
	var tz = Time.get_time_zone_from_system()
	if save_file:
		name_label.text = save_file.creature_name
		var time_dict = Time.get_datetime_dict_from_unix_time(save_file.last_saved + (tz['bias'] * 60))
		var lp_date = str(time_dict['day']) + "/" + str(time_dict['month']) + "/" + str(time_dict['year'])
		var lp_time = " - " + str(time_dict['hour']) + ":" + str(time_dict["minute"]) + ":" + str(time_dict["second"])
		date_label.text = lp_date + lp_time
		var icon_path = Globals.SAVE_ICON_FILE.replace("{}", str(save_file.id))
		if FileAccess.file_exists(icon_path):
			creature_icon.icon = load(icon_path)
		#category_icon.tooltip_string = "Category: %s" % sound_node.sound_category.category_name
		#creature_icon.icon = save_file.icon

func _on_hidden() -> void:
	pass
	#queue_free()

func _on_button_down() -> void:
	if save_file.has('id'):
		parent_menu.current_save_id = save_file.id
