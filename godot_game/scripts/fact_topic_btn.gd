extends Button

@export var category: Fact.FactCategory
@export var title_label: Label
@export var icon_btn: Button
@export var count_label: Label

var og_text
var fact_menu: PanelContainer
var fact_listing: MarginContainer

func setup(new_category, the_fact_menu):
	og_text = count_label.text
	fact_menu = the_fact_menu
	category = Fact.FactCategory.get(new_category)
	title_label.text = Fact.FactCategory.keys()[category]
	icon_btn.icon = Globals.get_fact_category_icon(category)
	
	Globals.item_unlocked.connect(update_text)
	update_text()
	
	var fact_listing_scene = load("res://scenes/UiScenes/fact_listing.tscn")
	fact_listing = fact_listing_scene.instantiate()
	fact_listing.category = category
	fact_menu.add_child.call_deferred(fact_listing)
	fact_listing.add_facts()
	fact_listing.visible = false


func update_text(_null=null, _null_2=null):
	var progress = Globals.get_fact_category_progress(category)
	count_label.text = og_text % progress


## When clicked add fact listing scene populated with facts matching this buttons category.
func _on_button_down() -> void:
	fact_listing.visible = true
