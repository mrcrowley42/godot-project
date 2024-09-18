extends Button
@export var category: Fact.FactCategory

@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")
	#var fact_scene = fact_window_scene.instantiate()
	#fact_menu.add_child(fact_scene)
#@onready var library = find_parent("Library")
@onready var fact_listing_scene = preload("res://scenes/UiScenes/fact_listing.tscn")
@onready var fact_menu = %FactsMenu

#@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")
#@onready var library = find_parent("Library")
#@onready var fact_menu = %FactsMenu

func _ready() -> void:
	text = Fact.FactCategory.keys()[category]


func _on_button_down() -> void:
	# temp stuff
	var fact_listing = fact_listing_scene.instantiate()
	
	fact_menu.add_child(fact_listing)
	fact_listing.add_facts()
	

	#var fact_scene = fact_window_scene.instantiate()
	#fact_menu.add_child(fact_scene)
