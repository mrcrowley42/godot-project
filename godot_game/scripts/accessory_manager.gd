class_name AccessoryManager extends ScriptNode

@onready var creature = find_parent("Creature")
var current_cosmetics: Array[String]
var position_dict: Dictionary
var unlockables = load("res://resources/unlockables.tres").unlockables
var unlockables_dict: Dictionary

## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends AnimatedSprite2D:
	func _init(cosmetic: CosmeticItem):
		self.sprite_frames = cosmetic.sprite
		# TODO will change depending on whether the correctly scaled versions of sprites are used.
		self.scale = Vector2(0.225, 0.225)


func _ready() -> void:
	for item in unlockables:
		unlockables_dict[item.name] = item
	
	for item in find_parent("Creature").creature_type.cosmetic_positions:
		position_dict[item.item] = item.position
	

## If the passed cosmetic item isn't already in the scene, and add it, at the location set
## for the current creature. If it does exist, remove that instance.
func toggle_cosmetic(cosmetic: CosmeticItem) -> void:
	if cosmetic.name not in current_cosmetics:
		var new_sprite = CosmeticSprite.new(cosmetic)
		new_sprite.name = cosmetic.name
		new_sprite.position = position_dict[cosmetic]  # lol
		# possibly link animation up with main sprite so frame rate meets up
		new_sprite.play()
		add_child(new_sprite, true)
		current_cosmetics.append(cosmetic.name)
	else:
		#remove_child(find_child(cosmetic.name))
		# Painful to do this with an array but whatever
		for i in range(len(current_cosmetics)):
			if current_cosmetics[i] == cosmetic.name:
				current_cosmetics.remove_at(i)


func save() -> Dictionary:
	return {"current_cosmetics": current_cosmetics}


func load(data) -> void:
	if data.has("current_cosmetics"):
		for item in data["current_cosmetics"]:
			toggle_cosmetic(unlockables_dict[item])
