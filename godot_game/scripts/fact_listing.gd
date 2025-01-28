extends MarginContainer

@export var heading: Node
@export var fact_container: Node
@export var fact_title_label: Label
@export var fact_body_label: Label
@export var source_label: Label

@onready var fact_btn_scene = preload("res://scenes/UiScenes/fact_btn.tscn")
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")

var category: Fact.FactCategory
var facts = load("res://resources/fact_list.tres")

var all_buttons: Array[Button]

func _ready() -> void:
	heading.text = "Facts: %s" % Fact.FactCategory.keys()[category]
	show_fact()  # empty


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func show_fact(fact: Fact=null, unlocked: bool=true):
	fact_body_label.modulate.a = 1
	source_label.text = ""
	
	if fact == null:
		fact_title_label.text = "Select a fact!"
		fact_body_label.text = ""
		return
	
	if not unlocked:
		fact_title_label.text = "Unknown"
		fact_body_label.text = "hint: " + fact.hint
		fact_body_label.modulate.a = .3
		return
	
	fact_title_label.text = fact.title
	fact_body_label.text = fact.fact
	source_label.text = "Source: " + fact.source

func fact_btn_pressed(btn: Button, fact: Fact, unlocked: bool):
	# no fact
	if btn.button_pressed:
		show_fact()
		return
	
	# display fact
	show_fact(fact, unlocked)
	for button in all_buttons:
		if button != btn:
			button.button_pressed = false


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
			btn.toggle_mode = true
			btn.button_pressed = false
			i += 1
			fact_container.add_child(btn)
			btn.connect("button_down", fact_btn_pressed.bind(btn, fact, unlocked))
			all_buttons.append(btn)
