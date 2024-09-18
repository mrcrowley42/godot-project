extends MarginContainer

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@export var heading: Node
@export var fact_container: Node
@onready var fact_btn_scene = preload("res://scenes/UiScenes/fact_btn.tscn")
var category: Fact.FactCategory
#var facts = load(factlist) <--- Store list of facts 

func _ready() -> void:
	heading.text = Fact.FactCategory.keys()[category] 


func _on_cancel_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func add_facts() -> void:
	#HERE FOR FACT IN THE FACT LIST GENERATE A NEW BUTTON
	# THEN EDIT THE FACT THAT IT POINTS TO 
	for i in range(6):
		var btn = fact_btn_scene.instantiate()
		btn.fact_to_display = load("res://resources/facts/example_fact.tres")
		fact_container.add_child(btn)
	#print(fact_container.get_children())
	## yep facts
	#add_child(fact_btn)
