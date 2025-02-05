extends MarginContainer

@export var heading: Node
@export var main_script: Node
@export var item_container: Node
@onready var save_listing_scene = load("res://scenes/UiScenes/save_file_listing.tscn")
@onready var btn_sfx = find_parent("MainMenu").find_child("BtnClick")
@onready var btn_group = load("res://resources/save_file_group.tres")

var current_save_id = null

func _ready() -> void:
	visible = false


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		add_saves()


func _on_back_button_down() -> void:
	btn_sfx.play()
	self.hide()


func _on_hidden() -> void:
	self.hide()  # ???


func add_saves() -> void:
	for save in main_script.grab_saves():
		var new_listing: Button = save_listing_scene.instantiate()
		new_listing.button_group = btn_group
		new_listing.save_file = save
		new_listing.parent_menu = self
		item_container.add_child(new_listing)
