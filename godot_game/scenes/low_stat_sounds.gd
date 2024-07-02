extends AudioStreamPlayer
class_name SfxManager
## A very basic sound effect manager.
## Attempts to stop sounds playing constantly and prevent race conditions.

@export_category("Sound Files")
@export var low_hunger: AudioStream
@export var low_fun: AudioStream
@export var low_regulation: AudioStream
@export var low_hydrate: AudioStream

@export_category("Settings")
## How long (in seconds) after a sound effect has finished playing can another one begin.
@export var cooldown_period: float = 20.0

@onready var creature: Creature = $".."

## Bool to keep track if the sound effect should still be on cooldown or not.
var on_cooldown: bool = false

func _process(_delta) -> void:
	var low_stats: Array[AudioStream] = []
	if creature.mp < 200:
		low_stats.append(low_hydrate)
	if creature.sp < 200:
		low_stats.append(low_regulation)
	if creature.ap < 200:
		low_stats.append(low_fun)
		
	queue_warning(low_stats.pick_random())

func _ready():
	var timer = Timer.new()
	timer.wait_time = cooldown_period
	timer.timeout.connect(done)
	timer.autostart = true
	timer.name = "CooldownTimer"
	add_child(timer)

func done() -> void:
	on_cooldown = false

func queue_warning(sound_file: AudioStream) -> void:	
	if not playing and not on_cooldown:
		stream = sound_file
		play()

## When a sound finishes, puts the player on cooldown until the cooldown period is elapsed.
func _on_finished() -> void:
	on_cooldown = true
