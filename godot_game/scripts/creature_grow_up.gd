extends Node2D

@onready var baby_sprite: AnimatedSprite2D = find_child("Baby")
@onready var adult_sprite: AnimatedSprite2D = find_child("Adult")
@onready var display_box: NinePatchRect = find_parent("UI").find_child("DisplayBox")

var creature_type: CreatureType
var creature: CreatureTypePart

var baby_position_dict: Dictionary
var adult_position_dict: Dictionary

var current_cosmetics: Array
var loaded_cosmetics: Dictionary

func _ready() -> void:
	var uid = int(DataGlobals.metadata_last_loaded[DataGlobals.CURRENT_CREATURE])
	creature_type = load(ResourceUID.get_id_path(uid))
	creature = creature_type.baby
	
	position = display_box.position - (display_box.size * display_box.scale) * .5
	position.y += 25
	baby_sprite.sprite_frames = creature.sprite_frames
	adult_sprite.sprite_frames = creature_type.adult.sprite_frames
	baby_sprite.animation = "idle"
	adult_sprite.animation = "idle"
	baby_sprite.play()
	adult_sprite.play()
	
	# build cosmetic positions dict
	for item in creature.cosmetic_positions:
		baby_position_dict[item.item] = item.position
	for item in creature_type.adult.cosmetic_positions:
		adult_position_dict[item.item] = item.position
	
	current_cosmetics = Globals.general_dict["current_cosmetics"]
	loaded_cosmetics = Globals.general_dict["loaded_cosmetics"]
	for item in current_cosmetics:
		add_cosmetic(loaded_cosmetics[item])
	
	baby_sprite.visible = true
	adult_sprite.visible = false


## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends AnimatedSprite2D:
	func _init(cosmetic: CosmeticItem):
		self.sprite_frames = cosmetic.sprite
		# TODO will change depending on whether the correctly scaled versions of sprites are used.

func add_cosmetic(cosmetic: CosmeticItem) -> void:
	var baby_cos = CosmeticSprite.new(cosmetic)
	var adult_cos = CosmeticSprite.new(cosmetic)
	
	baby_cos.name = cosmetic.name
	adult_cos.name = cosmetic.name
	var off = 1 / .225  # revert the scale positioning
	baby_cos.position = baby_position_dict[cosmetic] * off
	adult_cos.position = adult_position_dict[cosmetic] * off
	baby_sprite.add_child(baby_cos, true)
	adult_sprite.add_child(adult_cos, true)
	
	# WAIT
	await baby_sprite.frame_changed
	baby_cos.play()
	adult_cos.play()
