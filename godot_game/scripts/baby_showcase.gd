extends MarginContainer

@export var heading: Node
@export var preview: AnimatedSprite2D
@export var emote_btn: OptionButton

@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var showcase_scene = load("res://scenes/UiScenes/creature_showcase.tscn")
var baby: CreatureBaby

func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func update_animation(anim_name):
	preview.animation = anim_name.to_lower()


func setup():
	if not baby:
		return
	heading.text = "%s" % baby.name
	## by default start with child
	preview.sprite_frames = baby.baby_part.sprite_frames
	preview.autoplay = "idle"

	add_animation_names()
	update_animation("idle")

func get_highest_stage() -> int:
	var uid = Helpers.uid_str(baby)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	return encountered[uid]['max_stage_reached']

func _on_button_button_down() -> void:
	var showcase = showcase_scene.instantiate()
	showcase.creature = baby
	add_child(showcase)


func add_animation_names() -> void:
	var btn_dict = {}
	emote_btn.clear()
	emote_btn.add_item("EMOTION")
	emote_btn.set_item_disabled(0, true)
	var i = 1
	for anim_name in preview.sprite_frames.get_animation_names():
		btn_dict[anim_name] = i
		i += 1
		emote_btn.add_item(anim_name.capitalize())
	
	emote_btn.select(btn_dict['idle'])

func _on_emote_btn_item_selected(index: int) -> void:
	if index == 0:
		return
	var anim = emote_btn.get_item_text(index)
	update_animation(anim)
