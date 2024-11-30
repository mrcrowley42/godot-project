extends GridContainer

@onready var creature_list = load("res://resources/creature_list.tres")
@onready var creature_info_scene = load("res://scenes/UiScenes/creature_info.tscn")
@onready var creature_listing = load("res://scenes/UiScenes/creature_listing.tscn")
func _ready():
	for creature in creature_list.items:
		var btn = creature_listing.instantiate()
		btn.creature_data = creature
		add_child(btn)

#func _on_visibility_changed():
	#$"../..".scroll_vertical = 0
