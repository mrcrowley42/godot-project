class_name SfxManager extends AudioStreamPlayer
## A very basic sound effect manager.
## Attempts to stop sounds playing constantly and prevent race conditions.

@onready var notfication_bubble =  %NotificationBubble
@onready var notif = %Example
@export_category("Sound Files")
@export var low_hunger: AudioStream
@export var low_fun: AudioStream
@export var low_regulation: AudioStream
@export var low_hydrate: AudioStream
var states = {}

@export_category("Settings")
## How long (in seconds) after a sound effect has finished playing can another one begin.
@export var cooldown_period: float = 10.0

@onready var creature: Creature = $".."

## Bool to keep track if the sound effect should still be on cooldown or not.
var on_cooldown: bool = false


func _process(_delta) -> void:
	notfication_bubble.visible = playing
	if not on_cooldown:
		var low_stats: Array[AudioStream] = []
		var state_message = []
		if creature.mp < 200:
			low_stats.append(low_hydrate)
			state_message.append("thirsty")
			state_message.append("hungry")
			# adding hunger here as well to not conflict with pain sounds lol
			low_stats.append(low_hunger)
		if creature.sp < 200:
			low_stats.append(low_regulation)
			state_message.append("angry")
		if creature.ap < 200:
			state_message.append("bored")
			low_stats.append(low_fun)
		if not low_stats.is_empty():
			var blah = state_message.pick_random()
			var haha = states[blah]
			notif.text = blah
			queue_warning(haha)

func _ready() -> void:
	states = {'angry': low_hunger, 'thirsty': low_hydrate, 'hungry': low_hunger, 'bored': low_fun}
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
	on_cooldown = true
	

## When a sound finishes, puts the player on cooldown until the cooldown period is elapsed.
func _on_finished() -> void:
	on_cooldown = true
