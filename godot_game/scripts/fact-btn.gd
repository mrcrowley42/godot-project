extends Button

@onready var fact_window_scene = preload("res://scenes/UiScenes/fact_popup.tscn")

var fact_to_display: Fact = load("res://resources/facts/example_fact.tres")

func _ready() -> void:
	text = fact_to_display.title


func _on_button_down() -> void:
	var fact_scene = fact_window_scene.instantiate()
	fact_scene.fact = fact_to_display
	$"../../../../..".get_parent().add_child(fact_scene)
