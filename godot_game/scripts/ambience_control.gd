extends PanelContainer

@onready var label = find_child("SoundLabel")

func _ready() -> void:
	label.text = "BLAH BLAH BLAH"
