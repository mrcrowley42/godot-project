@icon("res://icons/creature.svg")
extends Node2D

class_name Creature
## Creature base class

## Colour to tint creature as HP approaches 0.
@export_color_no_alpha var dying_colour;
@export var max_hp: float = 1000.0
@export var max_mp: float = 1000.0
@export var max_sp: float = 1000
@export var max_ap: float = 1000

@export var creature_list: Array[Resource]

var hp:float
var mp:float
var sp:float
var ap:float

signal hp_changed()
signal sp_changed()
signal mp_changed()
signal ap_changed()

var stats = {
	'hp': damage_hp,
	'ap': damage_ap,
	'mp': damage_mp,
	'sp': damage_sp
}

func _ready() -> void:
	#var sprite = preload(creature_list[0])

	reset_stats()


func reset_stats() -> void:
	self.hp = max_hp
	self.mp = max_mp
	self.sp = max_sp
	self.ap = max_ap
	hp_changed.emit()
	sp_changed.emit()
	ap_changed.emit()
	mp_changed.emit()
	apply_dmg_tint()

## function to damage/heal the Creature (use a negative value to heal)
func dmg(amount:float, stat:String) -> void:
	stats[stat].call(amount)

	
func dead():
	get_tree().change_scene_to_file("res://scenes/dead.tscn")


## Tint the Create using the dying_colour set in inspector scaling the tint based on how low HP is.
func apply_dmg_tint() -> void:
	self.modulate.b = clampf(1 - (1 - self.hp/1000) + dying_colour.b,0,1)
	self.modulate.g = clampf(1 - (1 - self.hp/1000) + dying_colour.g,0,1)
	self.modulate.r = clampf(1 - (1 - self.hp/1000) + dying_colour.r,0,1)


func damage_hp(amount: float) -> void:
	self.hp -= amount
	if hp <= 0:
		call_deferred("dead")
	self.hp = clampf(self.hp, 0, max_hp)
	apply_dmg_tint()
	hp_changed.emit()

	
func damage_sp(amount):
	self.sp -= amount
	self.sp = clampf(self.sp, 0, max_sp)
	sp_changed.emit()


func damage_ap(amount):
	self.ap -= amount
	self.ap = clampf(self.ap, 0, max_ap)
	ap_changed.emit()

	
func damage_mp(amount):
	self.mp -= amount
	self.mp = clampf(self.mp, 0, max_mp)
	mp_changed.emit()

func save():
	return {"mp": mp, "sp": sp, "ap": ap, "hp": hp}
	
func load(data):
	# this is a bit cursed an requires names to match up
	# maybe this is a better way to do this but this at least
	# prevents the app from breaking when an old save file is present.
	for setting in ["mp", "ap", "sp"]:
		if data.has(setting):
			self[setting] = data[setting]
			var signal_name = setting + "_changed"
			self[signal_name].emit()
	# like having to call this here, this is kinda a mess
	# maybe it would be easier to just call everything like this every frame ?
	# 
	apply_dmg_tint()
