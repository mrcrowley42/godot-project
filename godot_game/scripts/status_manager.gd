## Script responsible for passive drain of Creature stats
class_name StatusManager extends ScriptNode

@export_category("Status Controls")
@export var hp_rate: float = 1
@export var hp_amount: float = 5
@export var water_rate: float = 4
@export var water_amount: float = 8
@export var food_rate: float = 10
@export var food_amount: float = 2
@export var fun_rate: float = 30
@export var fun_amount: float = 1
## Property that scales the damage values of all passive drain timers.
@export var time_multiplier: float = 0.5

signal finished_loading()

## Stores a reference to the scenes Creature.
@onready var creature: Creature = %Creature

var holiday_mode: bool = false

## Creates a new timer that loops [param rate] times per second,
## and executes the [param timeout_func] at the end of each loop.
func new_timer(rate: float, timeout_func: Callable) -> void:
	var timer = Timer.new()
	timer.wait_time = 1 / rate
	timer.autostart = true
	timer.timeout.connect(timeout_func)
	add_child(timer)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_timer(hp_rate, hp_timeout)
	new_timer(water_rate, water_timeout)
	new_timer(food_rate, food_timeout)
	new_timer(fun_rate, fun_timeout)


func hp_timeout() -> void:
	creature.dmg(hp_amount * time_multiplier, Creature.Stat.HP)


func water_timeout() -> void:
	creature.dmg(water_amount * time_multiplier, Creature.Stat.WATER)


func food_timeout() -> void:
	creature.dmg(food_amount * time_multiplier, Creature.Stat.FOOD)


func fun_timeout() -> void:
	creature.dmg(fun_amount * time_multiplier, Creature.Stat.FUN)


func save() -> Dictionary:
	return {"holiday_mode": holiday_mode}


func load(data):
	if data.has("holiday_mode"):
		holiday_mode = data["holiday_mode"]
	finished_loading.emit()
