extends Button

@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")
#@onready var library = find_parent("Library")
func _on_button_down() -> void:
	var fact_scene = fact_window_scene.instantiate()
	$"../../../../..".get_parent().add_child(fact_scene)
