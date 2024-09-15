extends Button

@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")
#@onready var library = find_parent("Library")
@onready var fact_menu = %FactsMenu
func _on_button_down() -> void:
	var fact_scene = fact_window_scene.instantiate()
	fact_menu.add_child(fact_scene)
