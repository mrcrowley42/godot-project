extends MarginContainer

@export var heading: Node
@export var fact_container: Node
@export var fact_title_label: Label
@export var fact_body_label: Label

@onready var fact_btn_scene = preload("res://scenes/UiScenes/fact_btn.tscn")
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

var category: Fact.FactCategory
var facts = load("res://resources/fact_list.tres")

func _ready() -> void:
	heading.text = "Facts: %s" % Fact.FactCategory.keys()[category]


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func fact_btn_pressed(btn, fact, unlocked):
	print(btn, fact, unlocked)

func is_unlocked(fact: Fact) -> bool:
	var unlocked_items = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_FACTS)
	var uid = str(ResourceLoader.get_resource_uid(fact.resource_path))
	return uid in unlocked_items or fact.unlocked

func add_facts() -> void:
	## kill them all >:)
	for child in fact_container.get_children():
		fact_container.remove_child(child)
	
	## add buttons :)
	var i = 1
	for fact in facts.facts:
		if fact.category == category:
			var btn: Button = fact_btn_scene.instantiate()
			var unlocked = is_unlocked(fact)
			btn.text = str(i) if unlocked else "???"
			i += 1
			fact_container.add_child(btn)
			btn.connect("button_down", fact_btn_pressed.bind(btn, fact, unlocked))
