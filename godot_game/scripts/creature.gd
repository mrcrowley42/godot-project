@icon("res://icons/class-icons/creature.svg")

## Creature base class.
class_name Creature extends Node2D

# ENUMS
enum LifeStage {EGG, BABY, CHILD, ADULT}
enum Stat {HP, WATER, FOOD, FUN}
enum Preference {LIKES, NEUTRAL, DISLIKES}

const dislike_multiplier: float = 0.5
const like_multiplier: float = 2.0

const CREATURE_SCALE: Vector2 = Vector2(.225, .225)
const EGG_SCALE: Vector2 = Vector2(1.5, 1.5)


## A Reference to the main sprite so it can be manipulated
@onready var accessory_manager: AccessoryManager = find_child("AccessoryManager")
@onready var main_sprite: MainSprite = %Main
@onready var pivot_offset: Control = %PivotOffset
@export var dying_colour: Color;
@export var clippy_area: Node
@export var xp_mulitplier: float = 1.0
@export var viewport_container: Node
@export var dislike_food_ach: Achievement
@export var lay_egg_ach: Achievement
@export var child_stage_ach: Achievement
@export var adult_stage_ach: Achievement

## XP required for the creature to reach the [param ADULT] [param LifeStage] stage
var xp_required: float
var egg_type: EggEntry
var baby_type: CreatureBaby
var creature_type: CreatureType
var creature: CreatureTypePart

# CREATURE STATS VARIABLES
var max_hp: float
var max_water: float
var max_food: float
var max_fun: float
var hp: float
var water_saturation: float = 0
var water: float
var food_saturation: float = 0
var food: float
var fun: float

var lock_xp: bool = false
var xp: float = 0
var life_stage: LifeStage
var creature_name: String
var egg_time_remaining: int = 0

var is_ready_to_hatch: bool = false
var is_ready_to_grow_up: bool = false
var is_ready_to_lay_egg: bool = false

var food_likes: Array[FoodItem.FoodType]
var food_dislikes: Array[FoodItem.FoodType]
var drink_likes: Array[DrinkItem.DrinkType]
var drink_dislikes: Array[DrinkItem.DrinkType]

var og_pos: Vector2
var zen: bool = false

# SIGNALS
signal hp_changed()
signal food_changed()
signal water_changed()
signal fun_changed()
signal xp_changed()
signal egg_time_remaining_changed()
signal ready_to_hatch()
signal ready_to_grow_up()
signal ready_to_lay_egg()

## Map of shorthand strings to corresponding damage function
var stats_dmg: Dictionary = {Stat.HP: damage_hp, Stat.FUN: damage_fun,
	Stat.WATER: damage_water, Stat.FOOD: damage_food}

## Map of shorthand strings to corresponding heal function
var stats_heal: Dictionary = {Stat.HP: add_hp, Stat.FUN: add_fun,
	Stat.WATER: add_water, Stat.FOOD: add_food}
	
var stats_val: Dictionary = {Stat.HP: 'hp', Stat.FUN: 'fun',
	Stat.WATER: 'water', Stat.FOOD: 'food'}

var stats_max: Dictionary = {Stat.HP: 'max_hp', Stat.FUN: 'max_fun',
	Stat.WATER: 'max_water', Stat.FOOD: 'max_food'}

## called when the creature is openned for the very first time
func creature_first_openned():
	setup_creature()
	reset_stats()

func setup_creature():
	@warning_ignore("int_as_enum_without_cast")
	life_stage = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_LIFE_STAGE))
	og_pos = position
	var egg_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_EGG_UID))
	var baby_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_BABY_UID))
	var creature_uid = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_TYPE_UID))
	egg_type = load(ResourceUID.get_id_path(egg_uid))
	if life_stage > 0:
		baby_type = load(ResourceUID.get_id_path(baby_uid))
		creature_type = load(ResourceUID.get_id_path(creature_uid))
	
	# should grow up?
	var has_grown_up = Globals.has_creature_just_grown_up
	if has_grown_up:
		Globals.has_creature_just_grown_up = false
		grow_up_one_stage()
	
	# cant use ternery here :(
	if life_stage == 0:
		creature = null
		egg_time_remaining = int(DataGlobals.get_creature_metadata_value(DataGlobals.CREATURE_EGG_TIME_REMAINING))
	else:
		creature = [null, baby_type.baby_part, creature_type.child, creature_type.adult][life_stage]
		setup_default_values(has_grown_up)
	setup_main_sprite()
	Globals.send_notification(Globals.NOTIFICATION_CREATURE_IS_LOADED)
	apply_dmg_tint()
	
	if is_ready_to_hatch and life_stage == LifeStage.EGG:
		ready_to_hatch.emit()
	if is_ready_to_grow_up and life_stage < LifeStage.ADULT and life_stage != LifeStage.EGG:
		ready_to_grow_up.emit()
	elif is_ready_to_lay_egg and life_stage == LifeStage.ADULT:
		ready_to_lay_egg.emit()
	
	if life_stage == LifeStage.EGG:
		Globals.unlock_achievement(lay_egg_ach)
	
	# do last
	print("creature has been setup")

## Update the [param sprite_frames] of the current creature based on the current [param life_stage]
func setup_main_sprite() -> void:
	if creature != null:
		main_sprite.sprite_frames = creature.sprite_frames
		main_sprite.scale = CREATURE_SCALE
	else:
		var egg_frames: SpriteFrames = SpriteFrames.new()
		egg_frames.add_animation("idle")
		egg_frames.add_frame("idle", egg_type.image)
		main_sprite.sprite_frames = egg_frames
		main_sprite.scale = EGG_SCALE
		main_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	main_sprite.animation = "idle"
	main_sprite.play()

func setup_default_values(has_grown_up=false):
	max_hp = creature.max_hp
	max_food = creature.max_food
	max_fun = creature.max_fun
	max_water = creature.max_water

	food_likes = creature.food_likes
	food_dislikes = creature.food_dislikes
	drink_likes = creature.drink_likes
	drink_dislikes = creature.drink_dislikes
	
	creature_name = creature_type.name
	xp_required = creature_type.xp_threshold
	
	if has_grown_up:
		reset_stats_silent()
	
	hp_changed.emit()
	food_changed.emit()
	fun_changed.emit()
	water_changed.emit()


## Add the specified [param amount] to the creature's existing xp.
func add_xp(amount: float) -> void:
	if amount <= 0 or lock_xp: return
	xp += amount

	# The creature is ready to become an adult
	if life_stage != LifeStage.ADULT and life_stage != LifeStage.EGG and xp >= xp_required and !is_ready_to_grow_up:
		is_ready_to_grow_up = true
		ready_to_grow_up.emit()
	elif life_stage == LifeStage.ADULT and xp >= xp_required and !is_ready_to_lay_egg:
		is_ready_to_lay_egg = true
		ready_to_lay_egg.emit()

	xp_changed.emit()


## Sets the Creatures current stats to their maximum value.
func reset_stats() -> void:
	lock_xp = true
	heal(max_hp, Stat.HP)
	heal(max_food - food, Stat.FOOD)
	heal(max_water - water, Stat.WATER)
	heal(max_fun, Stat.FUN)
	lock_xp = false

func reset_stat(stat: Stat) -> void:
	var maxim = [max_hp, max_water, max_food, max_fun][stat]
	var current = [hp, water, food, fun][stat]
	lock_xp = true
	heal(maxim - current, stat)
	lock_xp = false

## reset stats to max without calling stat heals or XP
func reset_stats_silent():
	hp = max_hp
	food = max_food
	water = max_water
	fun = max_fun


## function to heal a stat
func heal(amount: float, stat: Stat) -> void:
	stats_heal[stat].call(amount)

## Generialised function to damage the Creature
func dmg(amount: float, stat: Stat) -> void:
	stats_dmg[stat].call(amount)


## Change to game over scene.
func game_over():
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_IS_DEAD, true, DataGlobals.get_creature_id())
	DataGlobals.set_metadata_value(true, DataGlobals.CURRENT_CREATURE, "-1")
	create_save_icon()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/GameScenes/game_over.tscn")


## Tint the Create using the dying_colour set in inspector scaling the tint based on how low HP is.
func apply_dmg_tint() -> void:
	if creature == null:
		return
	main_sprite.modulate.b = clampf(1 - (1 - hp / max_hp) + dying_colour.b, 0, 1)
	main_sprite.modulate.g = clampf(1 - (1 - hp / max_hp) + dying_colour.g, 0, 1)
	main_sprite.modulate.r = clampf(1 - (1 - hp / max_hp) + dying_colour.r, 0, 1)


func add_hp(amount: float, multiplier: float = 1.0):
	assert(amount >= 0)
	var old_hp = hp
	hp = min(hp + (amount * multiplier), max_hp)
	add_xp(hp - old_hp)
	apply_dmg_tint()
	hp_changed.emit()

func damage_hp(amount: float) -> void:
	assert(amount >= 0)  # positive only
	if hp - amount <= 0:
		call_deferred("game_over")
	
	hp = max(hp - amount, 0)
	apply_dmg_tint()
	hp_changed.emit()


func add_fun(amount: float, multiplier: float = 1.0):
	assert(amount >= 0)
	var old_fun = fun
	fun = min(fun + (amount * multiplier), max_fun)
	add_xp(fun - old_fun)
	fun_changed.emit()

func damage_fun(amount) -> void:
	assert(amount >= 0)
	fun = max(fun - amount, 0)
	fun_changed.emit()


func get_food_preference(food_item: FoodItem) -> Preference:
	if food_item.type in food_likes: return Preference.LIKES
	elif food_item.type in food_dislikes: return Preference.DISLIKES
	return Preference.NEUTRAL

func consume_food(food_item: FoodItem):
	var preference_multi := 1.0
	var pref: Preference = get_food_preference(food_item)
	if pref == Preference.LIKES: 
		preference_multi = like_multiplier
		do_movement(Movement.HAPPY_BOUNCE)
		add_fun(20)
	elif pref == Preference.DISLIKES: 
		preference_multi = dislike_multiplier
		do_movement(Movement.CONFUSED_SHAKE)
		Globals.unlock_achievement(dislike_food_ach)
	add_food(food_item.amount, preference_multi)

func add_food(amount: float, multiplier: float = 1.0):
	assert(amount >= 0)
	var old_food = food
	var new_food = food + (amount * multiplier)
	food = min(new_food, max_food)
	food_saturation = max(0, new_food - max_food)  # remainder / excess
	add_xp(food - old_food)
	food_changed.emit()

func damage_food(amount) -> void:
	assert(amount >= 0)
	var new_saturation = food_saturation - amount
	food_saturation = max(0, new_saturation)
	food = max(food - abs(min(0, new_saturation)), 0)
	food_changed.emit()


func get_drink_preference(drink_item: DrinkItem) -> Preference:
	if drink_item.type in drink_likes: return Preference.LIKES
	elif drink_item.type in drink_dislikes: return Preference.DISLIKES
	return Preference.NEUTRAL

func consume_drink(drink_item: DrinkItem):
	var preference_multi := 1.0
	var pref: Preference = get_drink_preference(drink_item)
	if pref == Preference.LIKES: 
		preference_multi = like_multiplier
		do_movement(Movement.HAPPY_BOUNCE)
		add_fun(20)
	elif pref == Preference.DISLIKES: 
		preference_multi = dislike_multiplier
		do_movement(Movement.CONFUSED_SHAKE)
	add_water(drink_item.amount, preference_multi)

func add_water(amount: float, multiplier: float = 1.0):
	assert(amount >= 0)
	var old_water = water
	var new_water = water + (amount * multiplier)
	water = min(new_water, max_water)
	water_saturation = max(0, new_water - max_water)  # remainder / excess
	add_xp(water - old_water)
	water_changed.emit()

func damage_water(amount) -> void:
	assert(amount >= 0)
	var new_saturation = water_saturation - amount
	water_saturation = max(0, new_saturation)
	water = max(water - abs(min(0, new_saturation)), 0)
	water_changed.emit()

func reduce_egg_time_remaining(amount: int) -> void:
	if amount <= 0 or is_ready_to_hatch:
		return
	egg_time_remaining = max(0, egg_time_remaining - amount)
	if egg_time_remaining == 0:
		is_ready_to_hatch = true
		ready_to_hatch.emit()
	egg_time_remaining_changed.emit()

func get_current_cosmetics():
	return %AccessoryManager.current_cosmetics

func get_loaded_cosmetics():
	return %AccessoryManager.unlockables_dict

## change the animation without waiting for the frame change
func force_change_animation(anim_name: String):
	if not main_sprite.sprite_frames.has_animation(anim_name):
		if life_stage != LifeStage.EGG:
			printerr("current creature has no animation: " + anim_name)
		return false
	if anim_name == main_sprite.animation:
		return true
	main_sprite.animation = anim_name
	return true

## changes the animation and retains frame change timing
func change_animation(anim_name: String):
	await main_sprite.frame_changed
	return force_change_animation(anim_name)

func grow_up_one_stage():
	xp = 0
	life_stage = min(life_stage + 1, LifeStage.ADULT)
	is_ready_to_grow_up = false
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_LIFE_STAGE, life_stage)
	DataGlobals.set_new_highest_life_stage(Helpers.uid_str(creature_type), life_stage)
	
	if life_stage == LifeStage.CHILD:
		Globals.unlock_achievement(child_stage_ach)
	elif life_stage == LifeStage.ADULT:
		Globals.unlock_achievement(adult_stage_ach)

# -----------
#  MOVEMENT
# -----------

enum Movement {NOTHING, HAPPY_BOUNCE, CONFUSED_SHAKE, EGG_WIGGLE}

var amount_dict = {
	Movement.HAPPY_BOUNCE: 30,
	Movement.CONFUSED_SHAKE: 15,
	Movement.EGG_WIGGLE: .2
}

var current_movement: Movement = Movement.NOTHING
var movement_queue: Movement = Movement.NOTHING
var movement_start: float = 0

const MOVEMENT_TIME: float = 1;

func do_movement(movement: Movement):
	if current_movement != Movement.NOTHING:
		if movement != Movement.EGG_WIGGLE:
			movement_queue = movement
		return
	
	if life_stage != LifeStage.EGG:
		await main_sprite.frame_changed
	current_movement = movement
	movement_start = Time.get_unix_time_from_system()
	
	# attempt to use joy animation, otherwise use chill animation
	if movement == Movement.HAPPY_BOUNCE and not force_change_animation("joy"):
		force_change_animation("chill")
	if movement == Movement.CONFUSED_SHAKE:
		force_change_animation("confused")
	if movement == Movement.EGG_WIGGLE:
		reduce_egg_time_remaining(5)  # lol why not

func end_movement():
	position = og_pos
	current_movement = Movement.NOTHING
	if movement_queue != Movement.NOTHING:
		do_movement(movement_queue)
	else:
		%Notifcations.check_status()
	movement_queue = Movement.NOTHING

func _process(_delta: float) -> void:
	var rot = 0
	if life_stage == LifeStage.EGG:
		rot = sin(Time.get_unix_time_from_system() * .5) * .15
	
	if current_movement != Movement.NOTHING:
		var t = Time.get_unix_time_from_system() - movement_start
		if t >= MOVEMENT_TIME:
			end_movement()
			return
		
		var inv_percent = 1-(t / MOVEMENT_TIME)
		if current_movement == Movement.HAPPY_BOUNCE:
			position.y = og_pos.y + (-abs(sin(t * 8)) * amount_dict[current_movement]) * inv_percent
		
		if current_movement == Movement.CONFUSED_SHAKE:
			position.x = og_pos.x + (sin(t * 14) * amount_dict[current_movement]) * inv_percent
		
		if current_movement == Movement.EGG_WIGGLE:
			rot += (sin(t * 8) * amount_dict[current_movement]) * inv_percent
	
	if life_stage == LifeStage.EGG:
		pivot_offset.rotation = rot


# -------
#  SAVE
# -------

func get_save_uid() -> int:
	return DataGlobals.SAVE_CREATURE_UID

func create_save_icon() -> void:
	var capture = self.viewport_container.get_texture().get_image()
	var snapshot_region: Rect2i = capture.get_used_rect()
	var smaller_index = snapshot_region.size.min_axis_index()
	var expand_amount = abs(snapshot_region.size.x - snapshot_region.size.y) / 2
	for side in Helpers.smaller_axis_to_sides[smaller_index]:
		snapshot_region = snapshot_region.grow_side(side, expand_amount)
	var capture2: Image = capture.get_region(snapshot_region)
	var current_save_id = DataGlobals.get_global_metadata_value(DataGlobals.CURRENT_CREATURE)
	var filename = Globals.SAVE_ICON_FILE.replace("{}", str(current_save_id))
	capture2.resize(128,128,Image.INTERPOLATE_CUBIC)
	capture2.save_png(filename)


func save() -> Dictionary:
	create_save_icon()
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_LIFE_STAGE, life_stage)
	DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_EGG_TIME_REMAINING, egg_time_remaining)
	return {
		"water": water, "food": food, "fun": fun, "hp": hp, "xp": xp,
		"is_ready_to_hatch": is_ready_to_hatch,
		"is_ready_to_grow_up": is_ready_to_grow_up,
		"is_ready_to_lay_egg": is_ready_to_lay_egg
	}

func load(data) -> void:
	var prop_list = ["water", "fun", "food", "hp", "xp", 
					"is_ready_to_hatch", "is_ready_to_grow_up", "is_ready_to_lay_egg"]

	for property in prop_list:
		if data.has(property):
			self[property] = data[property]

			var signal_name = property + "_changed"
			if self.has_signal(signal_name):
				self[signal_name].emit()

	apply_dmg_tint()
	setup_creature()  # do last

func get_stat(stat: String) -> float:
	var stat_enum = Stat[stat]
	var stat_key = stats_val[stat_enum]
	return self[stat_key]

func get_stat_max(stat: String) -> float:
	var stat_enum = Stat[stat]
	var stat_key = stats_max[stat_enum]
	return self[stat_key]
