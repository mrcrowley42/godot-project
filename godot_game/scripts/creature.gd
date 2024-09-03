@icon("res://icons/class-icons/creature.svg")
class_name Creature extends Node2D

@onready var main_sprite: AnimatedSprite2D = %Main

## Colour to tint creature as HP approaches 0.
@export var dying_colour: Color;
@export var clippy_area: Node
@export var xp_mulitplier: float = 1.0

var creature_type: CreatureType
var max_hp: float
var max_water: float
var max_food: float
var max_fun: float
var xp_required: float = 1000  # XP required for the creature to reach the [param ADULT] [param LifeStage] stage

const DISLIKE_MULTIPLIER: float = 0.5
const LIKE_MULTIPLIER: float = 2.0

# ENUMS
enum FoodItem {NEUTRAL, TOAST, CHIPS, FRUIT}
enum LifeStage {CHILD, ADULT}
enum Stat {HP, WATER, FOOD, FUN}

# CREATURE STATS VARIABLES
var hp: float
var water: float
var food: float
var fun: float
var xp: float = 0
var ready_to_grow_up: bool = false
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

## Map of shorthand strings to corresponding damage function
var stats: Dictionary = {Stat.HP: damage_hp, Stat.FUN: damage_fun,
	Stat.WATER: damage_water, Stat.FOOD: damage_food}


func _ready():
	var uid = DataGlobals.metadata_last_loaded[DataGlobals.CURRENT_CREATURE]
	creature_type = load(ResourceUID.get_id_path(uid))
	main_sprite.sprite_frames = creature_type.sprite_frames
	set_up_default_values()
	
	if life_stage == LifeStage.CHILD:
		main_sprite.animation = "baby"

func set_up_default_values():
	max_hp = creature_type.max_hp
	max_food = creature_type.max_food
	max_fun = creature_type.max_fun
	max_water = creature_type.max_water
	
	likes = creature_type.likes
	dislikes = creature_type.dislikes
	creature_name = creature_type.name
	
	hp = max_hp
	food = max_food
	fun = max_fun
	water = max_water

## Add the specified [param amount] to the creature's existing xp.
func add_xp(amount: float) -> void:
	if amount <= 0: return
	xp += amount
	
	# the creature is ready to become an adult
	if life_stage != LifeStage.ADULT and xp >= xp_required and !ready_to_grow_up:
		ready_to_grow_up = true
	
	xp_changed.emit()

## Sets the Creatures current stats to their maximum value.
func reset_stats() -> void:
	dmg(-max_hp, Stat.HP)
	dmg(-max_food, Stat.FOOD)
	dmg(-max_water, Stat.WATER)
	dmg(-max_fun, Stat.FUN)

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
	if kind in likes: preference_multi = LIKE_MULTIPLIER
	elif kind in dislikes: preference_multi = DISLIKE_MULTIPLIER
	
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

func save() -> Dictionary:
	return {
		"water": water, "food": food, "fun": fun, "hp": hp, 
		"xp": xp, "ready_to_grow_up": ready_to_grow_up
	}

func load(data) -> void:
	var prop_list = ["water", "fun", "food", "hp", "xp", "ready_to_grow_up"]
	
	for property in prop_list:
		if data.has(property):
			self[property] = data[property]
			
			var signal_name = property + "_changed"
			if self.has_signal(signal_name):
				self[signal_name].emit()
	apply_dmg_tint()
