extends MarginContainer

@export var heading: Node
@export var preview: AnimatedSprite2D
@export var emote_btn: OptionButton

@export var lifestage_btn: OptionButton
@onready var btn_sfx = find_parent("Game").find_child("BtnClick")
@onready var showcase_scene = load("res://scenes/UiScenes/creature_showcase.tscn")
var creature: CreatureType
var stages = {1: "Child", 2: "Adult"}

func _on_back_button_down() -> void:
	btn_sfx.play()
	queue_free()


func _on_hidden() -> void:
	queue_free()


func update_animation(anim_name):
	preview.animation = anim_name.to_lower()


func setup():
	if not creature:
		return
	heading.text = "%s" % creature.name
	add_life_stages()
	## by default start with child
	preview.sprite_frames = creature.child.sprite_frames
	preview.autoplay = "idle"

	add_animation_names()
	update_animation("idle")

func get_highest_stage() -> int:
	var uid = Helpers.uid_str(creature)
	var encountered = DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	return encountered[uid]['max_stage_reached']

func add_life_stages() -> void:
	lifestage_btn.clear()
	lifestage_btn.add_item("LIFE STAGE")
	lifestage_btn.set_item_disabled(0, true)
	for i in [1, 2]:
		lifestage_btn.add_item(stages[i])
		if i > get_highest_stage():
			lifestage_btn.set_item_disabled(i, true)
	lifestage_btn.select(1)  # child by default


func _on_button_button_down() -> void:
	var showcase = showcase_scene.instantiate()
	showcase.creature = creature
	add_child(showcase)


func _on_stage_btn_item_selected(_index: int) -> void:
	if _index == 1: # child
		preview.sprite_frames = creature.child.sprite_frames
		preview.play()
		add_animation_names()

	elif _index == 2:
		if creature.adult:
			preview.sprite_frames = creature.adult.sprite_frames
			preview.play()
			add_animation_names()
	
	## reset emotion back to idle
	update_animation(emote_btn.get_item_text(emote_btn.selected))


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
