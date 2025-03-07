extends MarginContainer

@export var heading: Node
@export var description: Node
@export var preview: AnimatedSprite2D
@export var stat_window: Label
@export var grows_grid: GridContainer
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
var baby: CreatureBaby


func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()

func _on_hidden() -> void:
	queue_free()

func setup():
	heading.text = "%s" % baby.name
	description.text = "%s" % baby.desc
	preview.sprite_frames = baby.baby_part.sprite_frames
	preview.autoplay = "idle"
	
	var uid = Helpers.uid_str(baby)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_BABIES)
	var num_hatched = encountered[uid]['num_times_found']
	stat_window.text = stat_window.text % [num_hatched]
	
	for creature: CreatureType in [baby.grows_into_a, baby.grows_into_b]:
		var scene: Button = load("res://scenes/UiScenes/creature_listing.tscn").instantiate()
		scene.setup(creature)
		scene.custom_minimum_size = Vector2(70, 90)
		scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grows_grid.add_child(scene)
