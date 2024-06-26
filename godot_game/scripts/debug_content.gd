extends Node2D

@onready var creature = %Creature
@onready var UI = %UI_Overlay
@onready var stat_man = %StatusManager
@onready var music_track = %MainMusic


func _on_h_slider_value_changed(value):
	stat_man.time_multiplier = value
