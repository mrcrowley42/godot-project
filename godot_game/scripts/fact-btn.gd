extends Button

@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")
var fact_to_display: Fact = load("res://resources/facts/example_fact.tres")

func update_locked():
	var unlocked_items = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_FACTS)
	var uid = str(ResourceLoader.get_resource_uid(self.fact_to_display.resource_path))
	var is_unlocked = true if self.fact_to_display.unlocked else uid in unlocked_items
	self.disabled = !is_unlocked
	self.text = "?" if self.disabled else fact_to_display.title
	self.tooltip_text = fact_to_display.hint if disabled else ""

func _on_button_down() -> void:
	var fact_scene = fact_window_scene.instantiate()
	fact_scene.fact = fact_to_display
	$"../../../../..".get_parent().add_child(fact_scene)
