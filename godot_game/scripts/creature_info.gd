extends MarginContainer

@export var heading: Node
@export var description: Node
@export var preview: Node
@export var stat_window: Node
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var showcase_scene = load("res://scenes/UiScenes/creature_showcase.tscn")
var creature: CreatureType


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func setup():
	if not creature:
		return

	heading.text = "%s" % creature.name
	description.text = "%s" % creature.desc
	preview.sprite_frames = creature.baby.sprite_frames
	preview.autoplay = "idle"
	var uid = Helpers.uid_str(creature)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	var num_hatched = encountered[uid]['num_times_hatched']
	stat_window.text = stat_window.text % [num_hatched]


func _on_button_button_down() -> void:
	var showcase = showcase_scene.instantiate()
	showcase.creature = creature
	showcase.setup()
	add_child(showcase)
