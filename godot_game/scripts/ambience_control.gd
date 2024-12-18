extends PanelContainer

@onready var label = find_child("SoundLabel")
@onready var slider = find_child("VolumeSfx")
@onready var sound_icon = find_child("SoundIconNew")
@onready var category_icon: CustomTooltipButton = find_child("CategoryIcon")
var sound_node: Node 


func _ready() -> void:
	if sound_node:
		label.text = sound_node.sound_name
		slider.value = db_to_linear(sound_node.volume_db)
		category_icon.tooltip_string = "Category: %s" % sound_node.sound_category.category_name
		category_icon.icon = sound_node.sound_category.image


func _on_remove_btn_button_down() -> void:
	sound_node.queue_free()
	queue_free()
	Globals.send_notification(Globals.NOTIFICATION_AMBIENT_SOUNDS_REMOVED)


func _on_volume_sfx_value_changed(value: float) -> void:
	sound_node.volume_db = linear_to_db(slider.value)


func _on_hidden() -> void:
	queue_free()
