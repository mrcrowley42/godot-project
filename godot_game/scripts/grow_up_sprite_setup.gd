extends Node2D

@onready var parent: GrowUpToAdult = find_parent("GrowUp")
@onready var current_sprite: AnimatedSprite2D = find_child("Current")
@onready var next_sprite: AnimatedSprite2D = find_child("Next")
@onready var display_box: NinePatchRect = find_parent("UI").find_child("DisplayBox")

var egg: EggEntry
var creature_baby: CreatureBaby
var creature_type: CreatureType
var current_creature: CreatureTypePart
var next_creature: CreatureTypePart

var baby_position_dict: Dictionary
var adult_position_dict: Dictionary

var current_cosmetics: Array
var loaded_cosmetics: Dictionary
var move_buffers: Array[FloatBuffer] = []

func _ready() -> void:
	var current_life_stage = Globals.general_dict["current_life_stage"]
	Globals.general_dict.erase("current_life_stage")
	var egg_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_EGG_UID))
	var creature_baby_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_BABY_UID))
	var creature_type_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_TYPE_UID))
	egg = load(ResourceUID.get_id_path(egg_uid))
	creature_baby = load(ResourceUID.get_id_path(creature_baby_uid))
	creature_type = load(ResourceUID.get_id_path(creature_type_uid))
	current_creature = [null, creature_baby.baby_part, creature_type.child, creature_type.adult][current_life_stage]
	next_creature = [null, creature_baby.baby_part, creature_type.child, creature_type.adult][current_life_stage+1]
	
	position = display_box.position - (display_box.size * display_box.scale) * .5
	position.y += 25
	if current_creature:
		current_sprite.sprite_frames = current_creature.sprite_frames
	else:
		current_sprite.sprite_frames.add_frame("idle", egg.image)
	next_sprite.sprite_frames = next_creature.sprite_frames  # will never be an egg
	current_sprite.animation = "idle"
	next_sprite.animation = "idle"
	current_sprite.play()
	next_sprite.play()
	
	# build cosmetic positions dict
	if current_creature:
		for item in current_creature.cosmetic_positions:
			baby_position_dict[item.item] = item.position
		for item in next_creature.cosmetic_positions:
			adult_position_dict[item.item] = item.position
	
	current_cosmetics = Globals.general_dict["current_cosmetics"]
	Globals.general_dict.erase("current_cosmetics")
	loaded_cosmetics = Globals.general_dict["loaded_cosmetics"]
	Globals.general_dict.erase("loaded_cosmetics")
	
	for item in current_cosmetics:
		add_cosmetic(loaded_cosmetics[item])
	
	current_sprite.visible = true
	next_sprite.visible = false


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
	current_sprite.add_child(baby_cos, true)
	next_sprite.add_child(adult_cos, true)
	
	# WAIT
	await current_sprite.frame_changed
	baby_cos.play()
	adult_cos.play()


func do_start_tween():
	var middle: Vector2 = parent.mid_display_pos
	tween_sprite_to_goal(current_sprite, middle).connect("finished", %SlowTimer.start)


func tween_sprite_to_goal(sprite, goal: Vector2) -> Tween:
	var end_movement = func():
		move_buffers.clear()
	
	# move animation
	move_buffers = [FloatBuffer.new(sprite.global_position.x), FloatBuffer.new(sprite.global_position.y)]
	Globals.tween(move_buffers[0], "value", goal.x, 0., 1.)  # x pos to center
	Globals.tween(move_buffers[1], "value", goal.y - 50, 0., .6)  # up
	var t = Globals.tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN)
	t.connect("finished", end_movement)  # down
	return t

func _process(_delta):
	# move creature
	if move_buffers.size() > 0:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		global_position = new_p

class FloatBuffer:
	var value: float = 0.
	func _init(v: float):
		value = v


var i = -1;
func swap():
	current_sprite.visible = i % 2 == 0
	next_sprite.visible = i % 2 == 1

func _on_fast_timer_timeout() -> void:
	i += 1
	
	if i == 10: return  # stay an adult for 1 tick
	if i == 11:
		parent.finish_grow_up()
		return
	swap()

func _on_slow_timer_timeout() -> void:
	i += 1;
	
	if i == 4:
		%SlowTimer.stop()
		%FastTimer.start()
	swap()
