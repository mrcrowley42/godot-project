extends Node2D


class_name Stats


var Health = int()
var Hunger = int()
var Sleep = int()
var Joy = int()


# sets the stats of creatures for faster building and changes
func SetStats(BHealth, BHunger, BSleep, BJoy):
	Health = BHealth
	Hunger = BHunger
	Sleep = BSleep 
	Joy = BJoy


