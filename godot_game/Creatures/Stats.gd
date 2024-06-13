extends Node2D


class_name Stats


var Health = float()
var Hunger = float()
var Sleep = float()
var Joy = float()


# sets the stats of creatures for faster building and changes
func SetStats(BHealth, BHunger, BSleep, BJoy):
	Health = BHealth
	Hunger = BHunger
	Sleep = BSleep 
	Joy = BJoy


