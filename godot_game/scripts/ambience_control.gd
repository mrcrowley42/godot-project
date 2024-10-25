extends PanelContainer

@onready var label = find_child("SoundLabel")

var sound_node: Node 

func _ready() -> void:
	pass
	#label.text = sound_node.


func _on_remove_btn_button_down() -> void:
	pass # Replace with function body.


func _on_volume_sfx_value_changed(value: float) -> void:
	pass # Replace with function body.
