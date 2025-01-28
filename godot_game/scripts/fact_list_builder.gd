extends HBoxContainer

@export var fact_menu: PanelContainer

@onready var fact_category_scene = preload("res://scenes/UiScenes/topic_btn.tscn")


func _ready() -> void:
	## kill them all
	for child in get_children():
		remove_child(child)
	
	for category in Fact.FactCategory:
		var new_btn = fact_category_scene.instantiate()
		new_btn.setup(category, fact_menu)
		add_child(new_btn)
