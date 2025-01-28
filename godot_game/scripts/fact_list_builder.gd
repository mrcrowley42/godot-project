extends HBoxContainer

@export var fact_menu: PanelContainer

@onready var fact_category_scene = preload("res://scenes/UiScenes/topic_btn.tscn")


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		## kill them all
		for child in get_children():
			remove_child.call_deferred(child)
		
		for category in Fact.FactCategory:
			var new_btn = fact_category_scene.instantiate()
			new_btn.setup(category, fact_menu)
			add_child.call_deferred(new_btn)
