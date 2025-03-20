extends Node2D

@onready var parent: GrowUpToAdult = find_parent("GrowUp")
@onready var current_sprite: AnimatedSprite2D = find_child("CurrentCreature")
@onready var display_box: NinePatchRect = find_parent("UI").find_child("DisplayBox")

var creature_type: CreatureType
var current_creature: CreatureTypePart

var adult_position_dict: Dictionary
var current_cosmetics: Array
var loaded_cosmetics: Dictionary

func _ready() -> void:
	var creature_type_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_TYPE_UID))
	creature_type = load(ResourceUID.get_id_path(creature_type_uid))
	current_creature = creature_type.adult
	current_sprite.sprite_frames = current_creature.sprite_frames
	current_sprite.animation = "idle"
	current_sprite.play()
	
	position = display_box.position - (display_box.size * display_box.scale) * .5
	position.y += 25
	
	# build cosmetic positions dict
	if current_creature:
		for item in current_creature.cosmetic_positions:
			adult_position_dict[item.item] = item.position
	
	current_cosmetics = Globals.general_dict["current_cosmetics"]
	Globals.general_dict.erase("current_cosmetics")
	loaded_cosmetics = Globals.general_dict["loaded_cosmetics"]
	Globals.general_dict.erase("loaded_cosmetics")
	
	for item in current_cosmetics:
		add_cosmetic(loaded_cosmetics[item])
	current_sprite.visible = true


## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends AnimatedSprite2D:
	func _init(cosmetic: CosmeticItem):
		self.sprite_frames = cosmetic.sprite


func add_cosmetic(cosmetic: CosmeticItem) -> void:
	var adult_cos = CosmeticSprite.new(cosmetic)
	
	adult_cos.name = cosmetic.name
	var off = 1 / .225  # revert the scale positioning
	adult_cos.position = adult_position_dict[cosmetic] * off
	current_sprite.add_child(adult_cos, true)
	
	# WAIT
	await current_sprite.frame_changed
	adult_cos.play()
