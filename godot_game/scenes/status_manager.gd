extends Node2D

@export_category("Status Controls")
@export_group("Status drain controls")
@export var hp_rate: float = 1
@export var hp_amount: float = 5
@export var mp_rate: float = 4
@export var mp_amount: float = 8
@export var sp_rate: float = 10
@export var sp_amount: float = 2
@export var ap_rate: float = 30
@export var ap_amount: float = 1
@onready var creature = %Creature


func new_timer(rate, timeout_func):
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
	creature.dmg(hp_amount, 'hp')
	
func mp_timeout():
	creature.dmg(mp_amount, 'mp')

func sp_timeout():
	creature.dmg(sp_amount, 'sp')

func ap_timeout():
	creature.dmg(ap_amount, 'ap')
