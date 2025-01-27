extends Button

@onready var name_label = find_child("NameLabel")
@onready var date_label = find_child("DateLabel")
@onready var creature_icon: CustomTooltipButton = find_child("CreatureIcon")
var save_file


func _ready() -> void:
	if save_file:
		name_label.text = save_file.creature_name
		date_label.text = save_file.last_saved
		#category_icon.tooltip_string = "Category: %s" % sound_node.sound_category.category_name
		creature_icon.icon = save_file.icon


func _on_hidden() -> void:
	queue_free()
