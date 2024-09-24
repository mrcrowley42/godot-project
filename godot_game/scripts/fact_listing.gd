extends MarginContainer

@export var heading: Node
@export var fact_container: Node

@onready var fact_btn_scene = preload("res://scenes/UiScenes/fact_btn.tscn")
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

var category: Fact.FactCategory
var facts = load("res://resources/fact_list.tres")

func _ready() -> void:
	heading.text = Fact.FactCategory.keys()[category]


func _on_cancel_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


var unlocked_items = DataGlobals.load_metadata()['unlocked_facts']


func add_facts() -> void:
	for fact in facts.facts:
		var uid = str(ResourceLoader.get_resource_uid(fact.resource_path))
		var is_unlocked = true if fact.unlocked else uid in unlocked_items
		if fact.category == category:
			var btn = fact_btn_scene.instantiate()
			btn.fact_to_display = fact
			btn.disabled = !is_unlocked
			fact_container.add_child(btn)
