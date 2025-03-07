extends MarginContainer

@export var heading: Node
@export var description: Node
@export var preview: AnimatedSprite2D
@export var stat_window: Label
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
var adult: CreatureType


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()

func _on_hidden() -> void:
	queue_free()

func setup():
	heading.text = "%s" % adult.name
	description.text = "%s" % adult.desc
	preview.sprite_frames = adult.adult.sprite_frames
	preview.autoplay = "idle"
	
	var uid = Helpers.uid_str(adult)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	var num_hatched = encountered[uid]['num_times_found']
	stat_window.text = stat_window.text % [num_hatched]
