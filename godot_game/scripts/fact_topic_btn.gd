extends Button

@export var category: Fact.FactCategory
@export var title_label: Label
@export var icon_btn: Button
@export var count_label: Label

@onready var fact_listing_scene = preload("res://scenes/UiScenes/fact_listing.tscn")

var og_text
var fact_menu: PanelContainer

func setup(new_category, the_fact_menu):
	og_text = count_label.text
	fact_menu = the_fact_menu
	category = Fact.FactCategory.get(new_category)
	title_label.text = Fact.FactCategory.keys()[category]
	
	Globals.item_unlocked.connect(update_text)
	update_text()


func update_text(_null=null):
	var progress = Globals.get_fact_category_progress(category)
	count_label.text = og_text % progress


## When clicked add fact listing scene populated with facts matching this buttons category.
func _on_button_down() -> void:
	var fact_listing = fact_listing_scene.instantiate()
	fact_listing.category = category
	fact_menu.add_child(fact_listing)
	fact_listing.add_facts()
