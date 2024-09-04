class_name AccessoryManager extends ScriptNode

@onready var creature = find_parent("Creature")

## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends Sprite2D:
	func _init(cosmetic: CosmeticItem):
		# TODO add to cosmetic resource
		self.sprite_frames = cosmetic.sprite
		# TODO will change depending on whether the correctly scaled versions of sprites are used.
		self.scale = Vector2(0.225, 0.225)
		# TODO add to creature resource
		self.position = find_parent("Creature").cosmetic_offset[cosmetic]


## If the passed cosmetic item isn't already in the scene, and add it, at the location set
## for the current creature. If it does exist, remove that instance.
func toggle_cosmetic(cosmetic: CosmeticItem) -> void:
	if not is_inside_tree():
		var new_sprite = CosmeticSprite.new(cosmetic)
		new_sprite.name = cosmetic.name
		add_child(new_sprite)
	else:
		remove_child(find_child(cosmetic.name))
