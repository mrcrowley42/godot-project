class_name AccessoryManager extends ScriptNode

@onready var creature = find_parent("Creature")
var current_cosmetics
var position_dict: Dictionary

## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends AnimatedSprite2D:
	func _init(cosmetic: CosmeticItem):
		# TODO add to cosmetic resource
		self.sprite_frames = cosmetic.sprite
		# TODO will change depending on whether the correctly scaled versions of sprites are used.
		self.scale = Vector2(0.225, 0.225)
		# TODO add to creature resource


func _ready():
	for item in find_parent("Creature").creature_type.cosmetic_positions:
		position_dict[item.item] = item.position
	
	print(position_dict)

## If the passed cosmetic item isn't already in the scene, and add it, at the location set
## for the current creature. If it does exist, remove that instance.
func toggle_cosmetic(cosmetic: CosmeticItem) -> void:
	#if not is_inside_tree():
		var new_sprite = CosmeticSprite.new(cosmetic)
		new_sprite.name = cosmetic.name
		new_sprite.position = position_dict[cosmetic]  # lol
		add_child(new_sprite)
	#else:
		#remove_child(find_child(cosmetic.name))


func save() -> Dictionary:
	return {"current_cosmetics": current_cosmetics}


func load(data) -> void:
	if data.has("current_cosmetics"):
		for item in data["current_cosmetics"]:
			toggle_cosmetic(item)
