extends VBoxContainer

@onready var light_theme = load("res://themes/menu_btn_small.tres")
@onready var dark_theme = load("res://themes/menu_btn_dark.tres")

@onready var egg_list: EggList = load("res://resources/egg_list.tres")
@onready var baby_list: ResourceList = load("res://resources/baby_list.tres")
@onready var creature_list: ResourceList = load("res://resources/creature_list.tres")

@onready var creature_info_scene = load("res://scenes/UiScenes/creature_info.tscn")

@onready var egg_listing = load("res://scenes/UiScenes/egg_listing.tscn")
@onready var baby_listing = load("res://scenes/UiScenes/baby_listing.tscn")
@onready var creature_listing = load("res://scenes/UiScenes/creature_listing.tscn")

@export var grid_container: MarginContainer
@export var menu_btns_container: HBoxContainer

var selected_menu = 0

func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		update_menu_btns()
		generate_lists()
		DataGlobals.baby_discovered.connect(generate_lists)
		DataGlobals.creature_discovered.connect(generate_lists)

# _null parameter cause the signals pass discovered uid on emit
func generate_lists(_null=null):
	var egg_grid: GridContainer = grid_container.get_child(0)
	var baby_grid: GridContainer = grid_container.get_child(1)
	var creature_grid: GridContainer = grid_container.get_child(2)
	
	## clear lists
	for child in egg_grid.get_children():
		egg_grid.remove_child(child)
	for child in baby_grid.get_children():
		baby_grid.remove_child(child)
	for child in creature_grid.get_children():
		creature_grid.remove_child(child)
	
	## egg list
	for egg: EggEntry in egg_list.items:
		var button: Button = egg_listing.instantiate()
		button.setup(egg)
		egg_grid.add_child(button)
	
	## baby list
	for baby: CreatureBaby in baby_list.items:
		var button: Button = baby_listing.instantiate()
		button.setup(baby)
		baby_grid.add_child(button)
	
	## creature list
	for creature: CreatureType in creature_list.items:
		var button: Button = creature_listing.instantiate()
		button.setup(creature)
		creature_grid.add_child(button)

func update_menu_btns():
	var i = 0
	for btn: Button in menu_btns_container.get_children():
		btn.theme = light_theme if i == selected_menu else dark_theme
		grid_container.get_child(i).visible = i == selected_menu
		i += 1

func _on_egg_button_down() -> void:
	selected_menu = 0
	update_menu_btns()

func _on_baby_button_down() -> void:
	selected_menu = 1
	update_menu_btns()

func _on_child_button_down() -> void:
	selected_menu = 2
	update_menu_btns()
