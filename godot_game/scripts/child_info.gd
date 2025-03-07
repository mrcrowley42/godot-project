extends MarginContainer

@export var heading: Node
@export var description: Node
@export var preview: AnimatedSprite2D
@export var stat_window: Label
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
var child: CreatureType


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()

func _on_hidden() -> void:
	queue_free()

func setup():
	heading.text = "%s" % child.name
	description.text = "%s" % child.desc
	preview.sprite_frames = child.child.sprite_frames
	preview.autoplay = "idle"
	
	var uid = Helpers.uid_str(child)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	var num_hatched = encountered[uid]['num_times_found']
	stat_window.text = stat_window.text % [num_hatched]
