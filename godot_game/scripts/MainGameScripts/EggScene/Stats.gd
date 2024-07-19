extends Node2D


class_name Stats

@export_color_no_alpha var dying_colour;
var Health: float
var Hunger: float
var Sleep: float
var Joy: float
var Max_health: float
var Max_Hunger: float
var Max_Sleep: float
var Max_Joy: float

# sets the stats of creatures for faster building and changes
func set_stats(BHealth, BHunger, BSleep, BJoy):
	Health = BHealth
	Hunger = BHunger
	Sleep = BSleep 
	Joy = BJoy

func max_stats(m_health, m_hunger, m_sleep, m_joy):
	Max_health = m_health
	Max_Hunger = m_hunger
	Max_Joy = m_joy
	Max_Sleep = m_sleep
	

## Tint the Create using the dying_colour setruet in inspector scaling the tint based on how low HP is.
func apply_dmg_tint():
	self.modulate.b = clampf(1 - (1 - self.health/1000) + dying_colour.b,0,1)
	self.modulate.g = clampf(1 - (1 - self.health/1000) + dying_colour.g,0,1)
	self.modulate.r = clampf(1 - (1 - self.health/1000) + dying_colour.r,0,1)
	
	
func dead():
	get_tree().change_scene_to_file("res://scenes/dead.tscn")
