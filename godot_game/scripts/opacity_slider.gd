extends HSlider
@export var clippy_area: Node
@onready var label = find_child("Value")

func _ready() -> void:
	_on_value_changed(clippy_area.clippy_opacity)
	

func _on_value_changed(_value: float) -> void:
	clippy_area.clippy_opacity = _value
	label.text = str(_value*100.0)
