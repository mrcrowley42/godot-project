@icon("res://icons/class-icons/creature.svg")
extends Node2D

class_name Creature
## Creature base class.

## Colour to tint creature as HP approaches 0.
@export_color_no_alpha var dying_colour: Color;
@export var max_hp: float = 1000
@export var max_water: float = 1000
@export var max_food: float = 1000
@export var max_fun: float = 1000
@export var xp_required: float
@onready var main_sprite = %Main
@export var clippy_area: Node

enum LifeStage {Egg, Child, Adult}

var hp: float
var water: float
var food: float
var fun: float
var xp: float
var life_stage: LifeStage

signal hp_changed()
signal food_changed()
signal water_changed()
signal fun_changed()
signal xp_changed()

var stats: Dictionary = {
	'hp': damage_hp,
	'fun': damage_fun,
	"water": damage_water,
	'food': damage_food
}

func add_xp(amount):
	xp += amount
	xp_changed.emit()
	if xp > xp_required:
		level_up()

func level_up():
	pass
	#life_stage = LifeStage.Adult

func _ready() -> void:
	reset_stats()

## Sets the Creatures current stats to their maximum value.
func reset_stats() -> void:
	dmg(-max_hp, 'hp')
	dmg(-max_food, 'food')
	dmg(-max_water, 'water')
	dmg(-max_fun, 'fun')

## function to damage/heal the Creature (use a negative value to heal)
func dmg(amount: float, stat: String) -> void:
	#add_xp(100)
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
	self.hp -= amount
	if hp <= 0:
		call_deferred("game_over")
	self.hp = clampf(self.hp, 0, max_hp)
	apply_dmg_tint()
	hp_changed.emit()
	
func damage_food(amount) -> void:
	self.food -= amount
	self.food = clampf(self.food, 0, max_food)
	food_changed.emit()

func damage_fun(amount) -> void:
	self.fun -= amount
	self.fun = clampf(self.fun, 0, max_fun)
	fun_changed.emit()
	
func damage_water(amount) -> void:
	self.water -= amount
	self.water = clampf(self.water, 0, max_water)
	water_changed.emit()

func save() -> Dictionary:
	return {"water": water, "food": food, "fun": fun, "hp": hp, "xp": xp}
	
func load(data) -> void:
	var stat_list = ["water", "fun", "food", "xp"]
	if not find_parent("Game").debug_mode:
		stat_list.append("hp")
	for setting in stat_list:
		if data.has(setting):
			self[setting] = data[setting]
			var signal_name = setting + "_changed"
			self[signal_name].emit()
	apply_dmg_tint()
