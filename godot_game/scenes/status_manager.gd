extends Node2D

@export_category("Status Controls")
@export_group("Status drain controls")
@export var hp_rate: float = 1
@export var hp_amount: float = 5
@export var mp_rate: float = 4
@export var mp_amount: float = 8
@onready var creature = %Creature

# Called when the node enters the scene tree for the first time.
func _ready():
	hp_timeout()
	mp_timeout()
	pass # Replace with function body.


func hp_timeout():
	creature.dmg(hp_amount, 'hp')
	get_tree().create_timer(1/hp_rate).timeout.connect(hp_timeout)
	
func mp_timeout():
	creature.dmg(hp_amount, 'mp')
	get_tree().create_timer(1/mp_rate).timeout.connect(mp_timeout)
