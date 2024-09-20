extends Button

@export var category: Fact.FactCategory

@onready var fact_listing_scene = preload("res://scenes/UiScenes/fact_listing.tscn")
@onready var fact_menu = %FactsMenu

func _ready() -> void:
	text = Fact.FactCategory.keys()[category]


## When clicked add fact listing scene populated with facts matching this buttons category.
func _on_button_down() -> void:
	var fact_listing = fact_listing_scene.instantiate()
	fact_listing.category = category
	fact_menu.add_child(fact_listing)
	fact_listing.add_facts()
