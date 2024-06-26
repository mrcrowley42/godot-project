#@icon("res://icons/gear.svg")
extends Node2D

class_name StatusManager
## Script responsible for passive drain of Creature stats

@export_category("Status Controls")
@export_group("Passive drain controls")
@export var hp_rate: float = 1
@export var hp_amount: float = 5
@export var mp_rate: float = 4
@export var mp_amount: float = 8
@export var sp_rate: float = 10
@export var sp_amount: float = 2
@export var ap_rate: float = 30
@export var ap_amount: float = 1

@export var time_multiplier: float = 1.0

@onready var creature: Node2D = %Creature

## Creates a new timer that loops [param rate] times per second,
## and executes the [param timeout_func] at the end of each loop.
func new_timer(rate: float, timeout_func: Callable) -> void:
	var timer = Timer.new()
	timer.wait_time = 1 / rate
	timer.autostart = true
	timer.timeout.connect(timeout_func)
	add_child(timer)

# Called when the node enters the scene tree for the first time.
func _ready():
	new_timer(hp_rate, hp_timeout)
	new_timer(mp_rate, mp_timeout)
	new_timer(sp_rate, sp_timeout)
	new_timer(ap_rate, ap_timeout)

func hp_timeout():
	creature.dmg(hp_amount * time_multiplier, 'hp')
	
func mp_timeout():
	creature.dmg(mp_amount * time_multiplier , 'mp')

func sp_timeout():
	creature.dmg(sp_amount * time_multiplier, 'sp')

func ap_timeout():
	creature.dmg(ap_amount * time_multiplier, 'ap')
