extends Button

signal selected(i)
var egg: EggEntry
var parent_name: String
var inx: int


@export var egg_name_label: Label
@export var parent_label: Label
@export var icon_btn: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon_btn.icon = egg.image
	egg_name_label.text = egg.name
	parent_label.text = 'Parent: %s' % parent_name


func _on_button_down() -> void:
	selected.emit(inx)
