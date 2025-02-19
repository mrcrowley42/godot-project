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
@export_category("Neglect Properties")
## Threshold in days for when bonus xp becomes neglect
@export var neglect_threshold: float = 0.01
@export var neglect_penalty_multiplier: float = 1.0
@export var bonus_xp_multiplier: float = 100
@export var bonus_xp_round_to: float = 0.1
## Stats won't drain past this percentage of the stat's max value 
@export var neglect_limit: float = .05

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


func toggle_holiday_mode():
	holiday_mode = !holiday_mode
	DataGlobals.set_metadata_value(true, DataGlobals.HOLIDAY_MODE, holiday_mode)

func _notification(what):
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		holiday_mode = DataGlobals.get_global_metadata_value(DataGlobals.HOLIDAY_MODE)
	finished_loading.emit()


func hp_timeout() -> void:
	creature.dmg(hp_amount * time_multiplier, Creature.Stat.HP)

func water_timeout() -> void:
	creature.dmg(water_amount * time_multiplier, Creature.Stat.WATER)

func food_timeout() -> void:
	creature.dmg(food_amount * time_multiplier, Creature.Stat.FOOD)

func fun_timeout() -> void:
	creature.dmg(fun_amount * time_multiplier, Creature.Stat.FUN)
