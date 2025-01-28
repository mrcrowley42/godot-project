extends MarginContainer

@export var heading: Node
@export var fact_container: Node
@onready var save_listing_scene = load("res://scenes/UiScenes/save_file_listing.tscn")

@onready var fact_btn_scene = preload("res://scenes/UiScenes/fact_btn.tscn")
#@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

var category: Fact.FactCategory
var facts = load("res://resources/fact_list.tres")

func _ready() -> void:
	for i in range(4):
		var new_listing = save_listing_scene.instantiate()
		fact_container.add_child(new_listing)

	#heading.text = "Facts: %s" % Fact.FactCategory.keys()[category]


func _on_back_button_down() -> void:
	#btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func add_facts() -> void:
	for fact in facts.facts:
		if fact.category == category:
			var btn = fact_btn_scene.instantiate()
			btn.fact_to_display = fact
			btn.update_locked()
			fact_container.add_child(btn)
