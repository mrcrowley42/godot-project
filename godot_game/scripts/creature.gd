@icon("res://icons/class-icons/creature.svg")

## Creature base class.
class_name Creature extends Node2D

# ENUMS
enum FoodItem {NEUTRAL, TOAST, CHIPS, FRUIT}
enum LifeStage {CHILD, ADULT}
enum Stat {HP, WATER, FOOD, FUN}

const dislike_multiplier: float = 0.5
const like_multiplier: float = 2.0


## A Reference to the main sprite so it can be manipulated
@onready var accessory_manager: AccessoryManager = find_child("AccessoryManager")
@onready var main_sprite = %Main
@export var dying_colour: Color;
@export var clippy_area: Node
@export var xp_mulitplier: float = 1.0


## XP required for the creature to reach the [param ADULT] [param LifeStage] stage
var xp_required: float
var creature_type: CreatureType
var creature: CreatureTypePart

# CREATURE STATS VARIABLES
var max_hp: float
var max_water: float
var max_food: float
var max_fun: float
var hp: float
var water: float
var food: float
var fun: float

var lock_xp: bool = false
var xp: float = 0
var is_ready_to_grow_up: bool = false
var life_stage: LifeStage
var likes: Array
var dislikes: Array
var creature_name: String

# SIGNALS
signal hp_changed()
signal food_changed()
signal water_changed()
signal fun_changed()
signal xp_changed()
signal ready_to_grow_up()

## Map of shorthand strings to corresponding damage function
var stats: Dictionary = {Stat.HP: damage_hp, Stat.FUN: damage_fun,
	Stat.WATER: damage_water, Stat.FOOD: damage_food}

func setup_creature():
	var uid = int(DataGlobals.get_metadata_value(DataGlobals.CURRENT_CREATURE))
	creature_type = load(ResourceUID.get_id_path(uid))
	
	# should grow up?
	if Globals.general_dict.has("grow_creature_up"):
		Globals.general_dict.erase("grow_creature_up")
		grow_up_one_stage()
	
	creature = creature_type.baby if life_stage == LifeStage.CHILD else creature_type.adult
	setup_default_values()
	setup_main_sprite()
	Globals.send_notification(Globals.NOTIFICATION_CREATURE_IS_LOADED)
	apply_dmg_tint()
	
	if is_ready_to_grow_up and life_stage < LifeStage.ADULT:
		ready_to_grow_up.emit()

## Update the [param sprite_frames] of the current creature based on the current [param life_stage]
func setup_main_sprite() -> void:
	main_sprite.sprite_frames = creature.sprite_frames
	main_sprite.animation = "idle"
	main_sprite.play()

func setup_default_values():
	max_hp = creature.max_hp
	max_food = creature.max_food
	max_fun = creature.max_fun
	max_water = creature.max_water

	likes = creature.likes
	dislikes = creature.dislikes
	creature_name = creature_type.name
	xp_required = creature_type.xp_required_for_adult
	
	hp_changed.emit()
	food_changed.emit()
	fun_changed.emit()
	water_changed.emit()


## Add the specified [param amount] to the creature's existing xp.
func add_xp(amount: float) -> void:
	if amount <= 0 or lock_xp: return
	xp += amount

	# The creature is ready to become an adult
	if life_stage != LifeStage.ADULT and xp >= xp_required and !is_ready_to_grow_up:
		is_ready_to_grow_up = true
		ready_to_grow_up.emit()

	xp_changed.emit()


## Sets the Creatures current stats to their maximum value.
func reset_stats() -> void:
	lock_xp = true
	dmg(-max_hp, Stat.HP)
	dmg(-max_food, Stat.FOOD)
	dmg(-max_water, Stat.WATER)
	dmg(-max_fun, Stat.FUN)
	lock_xp = false


## Generialised function to damage/heal the Creature (use a negative value to heal)
func dmg(amount: float, stat: Stat) -> void:
	stats[stat].call(amount)


## Change to game over scene.
func game_over():
	get_tree().change_scene_to_file("res://scenes/GameScenes/game_over.tscn")


## Tint the Create using the dying_colour set in inspector scaling the tint based on how low HP is.
func apply_dmg_tint() -> void:
	main_sprite.modulate.b = clampf(1 - (1 - hp / max_hp) + dying_colour.b, 0, 1)
	main_sprite.modulate.g = clampf(1 - (1 - hp / max_hp) + dying_colour.g, 0, 1)
	main_sprite.modulate.r = clampf(1 - (1 - hp / max_hp) + dying_colour.r, 0, 1)


func damage_hp(amount: float) -> void:
	var temp_hp = hp
	self.hp = clampf(self.hp - amount, 0, max_hp)
	if hp <= 0:
		call_deferred("game_over")
	if hp - temp_hp > 0:
		add_xp(hp - temp_hp * xp_mulitplier)

	apply_dmg_tint()
	hp_changed.emit()


func damage_food(amount, kind: FoodItem = FoodItem.NEUTRAL) -> void:
	var preference_multi := 1.0
	if kind in likes: preference_multi = like_multiplier
	elif kind in dislikes: preference_multi = dislike_multiplier

	var temp_food = food
	self.food = clampf(self.food - amount, 0, max_food)
	if food - temp_food > 0:
		add_xp((food - temp_food) * xp_mulitplier * preference_multi)

	food_changed.emit()


func damage_fun(amount) -> void:
	var temp_fun = fun
	self.fun = clampf(self.fun - amount, 0, max_fun)
	if fun - temp_fun > 0:
		add_xp(fun - temp_fun * xp_mulitplier)

	fun_changed.emit()


func damage_water(amount) -> void:
	var temp_water = water
	self.water = clampf(self.water - amount, 0, max_water)
	if water - temp_water > 0:
		add_xp(water - temp_water * xp_mulitplier)

	water_changed.emit()

func get_current_cosmetics():
	return %AccessoryManager.current_cosmetics

func get_loaded_cosmetics():
	return %AccessoryManager.unlockables_dict

## changes the animation and retains frame change timing
func change_animation(anim_name: String):
	if not main_sprite.sprite_frames.has_animation(anim_name):
		print_rich("[color=red]current creature has no animation: " + anim_name)
		return
	
	await main_sprite.frame_changed
	main_sprite.animation = anim_name

func grow_up_one_stage():
	xp = 0
	life_stage += 1
	is_ready_to_grow_up = false
	DataGlobals.set_new_highest_life_stage(Helpers.uid_str(creature_type), life_stage)


func save() -> Dictionary:
	return {
		"water": water, "food": food, "fun": fun, "hp": hp,
		"xp": xp, "is_ready_to_grow_up": is_ready_to_grow_up,
		"life_stage": life_stage
	}


func load(data) -> void:
	var prop_list = ["water", "fun", "food", "hp", "xp", 
					"is_ready_to_grow_up", "life_stage"]

	for property in prop_list:
		if data.has(property):
			self[property] = data[property]

			var signal_name = property + "_changed"
			if self.has_signal(signal_name):
				self[signal_name].emit()

	apply_dmg_tint()
	setup_creature()  # do last
