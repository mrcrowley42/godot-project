extends MarginContainer

@export var main_script: Node
@export var select_btn: Button
@export var item_container: Node

@onready var egg_listing_scene = load("res://scenes/UiScenes/pending_egg_listing.tscn")
@onready var btn_sfx = find_parent("MainMenu").find_child("BtnClick")

var currently_selected: int


func _ready() -> void:
	visible = false
	select_btn.disabled = true


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		add_eggs()


func _on_back_button_down() -> void:
	btn_sfx.play()
	self.hide()

func _on_load_btn_button_down() -> void:
	var pending_eggs: Array = DataGlobals.get_global_metadata_value(DataGlobals.PENDING_EGGS)
	var egg_data = pending_eggs.pop_at(currently_selected)
	var egg: EggEntry = load(ResourceUID.get_id_path(int(egg_data['egg_uid'])))
	
	DataGlobals.set_metadata_value(true, DataGlobals.PENDING_EGGS, pending_eggs)
	var id = DataGlobals.create_new_egg_creature(egg, egg_data['parent_id'])
	DataGlobals.set_metadata_value(true, DataGlobals.CURRENT_CREATURE, str(id))
	btn_sfx.play()
	DataGlobals.save_data()
	main_script.go_to_main_game()

func egg_selected(index):
	select_btn.disabled = false
	currently_selected = index

func add_eggs() -> void:
	var inx = 0
	for pending_egg_data in DataGlobals.get_global_metadata_value(DataGlobals.PENDING_EGGS):
		var egg_uid = pending_egg_data['egg_uid']
		var parent_id = int(pending_egg_data['parent_id'])
		var parent_name = DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_NAME, parent_id) if DataGlobals.does_creature_exist(parent_id) else 'Unknown'
		var egg: EggEntry = load(ResourceUID.get_id_path(int(egg_uid)))
		
		var new_listing: Button = egg_listing_scene.instantiate()
		new_listing.parent_name = parent_name
		new_listing.egg = egg
		new_listing.inx = inx
		item_container.add_child(new_listing)
		new_listing.connect("selected", egg_selected)
		inx += 1


func _on_hidden() -> void:
	select_btn.disabled = true
