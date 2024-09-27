class_name AccessoryManager extends ScriptNode

## Manages cosmetic items for the creature.

@onready var creature = find_parent("Creature")
@onready var unlockables = load("res://resources/unlockables.tres").unlockables

var current_cosmetics: Array
var position_dict: Dictionary
var unlockables_dict: Dictionary

var ready_to_place_cosmetics: bool = false

## Class to define a cosmetic as it appears in game.
class CosmeticSprite extends AnimatedSprite2D:
	func _init(cosmetic: CosmeticItem):
		self.sprite_frames = cosmetic.sprite
		# TODO will change depending on whether the correctly scaled versions of sprites are used.
		self.scale = Vector2(0.225, 0.225)


func _ready() -> void:
	# Build dictionary for each unlockable item with the key being the items name.
	for item in unlockables:
		unlockables_dict[item.name] = item

func _notification(noti: int) -> void:
	if noti == Globals.NOTIFICATION_CREATURE_IS_LOADED:
		if DataGlobals.has_only_metadata():
			place_all_cosmetics()
		else:
			set_ready()


## we wait for both creature to load and for this to load
func set_ready():
	if ready_to_place_cosmetics:
		place_all_cosmetics()
	ready_to_place_cosmetics = true

func place_all_cosmetics():
	# Build dictionary for each cosmetic items appropriate position for the current creature
	for item in find_parent("Creature").creature.cosmetic_positions:
		position_dict[item.item] = item.position
	
	# place cosmetics on creature
	print(current_cosmetics)
	for cosmetic in current_cosmetics:
		place_cosmetic(unlockables_dict[cosmetic])


func place_cosmetic(cosmetic: CosmeticItem):
	var new_sprite = CosmeticSprite.new(cosmetic)
	new_sprite.name = cosmetic.name
	new_sprite.position = position_dict[cosmetic]
	add_child(new_sprite, true)
	# Should maintain sync with main sprite
	await %Main.frame_changed
	new_sprite.play()

## If the passed cosmetic item isn't already in the scene, and add it, at the location set
## for the current creature. If it does exist, remove that instance.
func toggle_cosmetic(cosmetic: CosmeticItem) -> void:
	if cosmetic.name not in current_cosmetics:
		place_cosmetic(cosmetic)
		current_cosmetics.append(cosmetic.name)
	else:
		# this is ridiculous
		var children = get_children()
		for child in children:
			if child.name == cosmetic.name:
				remove_child(child)

		# Painful to do this with an array but whatever
		for i in range(len(current_cosmetics)):
			if current_cosmetics[i] == cosmetic.name:
				current_cosmetics.remove_at(i)
				break


func save() -> Dictionary:
	return {"current_cosmetics": current_cosmetics}


func load(data) -> void:
	if data.has("current_cosmetics"):
		current_cosmetics = data["current_cosmetics"]
	set_ready()
