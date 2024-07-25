@icon("res://icons/class-icons/bell-fill.svg")
extends Node

## Manages the visual and audio notifications for a Creature.
@export_category("Files")
@export_group("Sound Files")
@export var low_hunger: AudioStream
@export var low_fun: AudioStream
@export var low_regulation: AudioStream
@export var low_hydrate: AudioStream
@export_category("Settings")
## How long (in seconds) after a sound effect has finished playing can another one begin.
@export var cooldown_period: float = 10.0
## How long (in seconds) after a sound effect has finished should the visual prompt linger.
@export var notifcation_linger: float = 0.0

@onready var notfication_bubble = %NotificationBubble
@onready var notif_sounds = %LowStatSounds
@onready var notif = %Example
@onready var creature: Creature = $".."
@onready var cooldown_timer = Timer.new()

var states = {}
## Bool to keep track whether notifications should still be on cooldown or not.
var on_cooldown: bool = false

func _ready() -> void:
	states = {'angry': low_hunger, 'thirsty': low_hydrate, 'hungry': low_hunger, 'bored': low_fun}
	cooldown_timer.wait_time = cooldown_period
	cooldown_timer.timeout.connect(done)
	cooldown_timer.autostart = true
	cooldown_timer.name = "CooldownTimer"
	add_child(cooldown_timer)

func _process(_delta) -> void:
	notfication_bubble.visible = notif_sounds.playing
	if on_cooldown:
		return
		
	var low_stats: Array[AudioStream] = []
	var state_message = []
	if creature.mp < 200:
		low_stats.append(low_hydrate)
		state_message.append("thirsty")
		#state_message.append("hungry")
		# adding hunger here as well to not conflict with pain sounds lol
		#low_stats.append(low_hunger)
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

func done() -> void:
	on_cooldown = false
	
func queue_warning(sound_file: AudioStream) -> void:
	if not notif_sounds.playing and not on_cooldown:
		notif_sounds.stream = sound_file
		notif_sounds.play()
	on_cooldown = true

## When a sound finishes, puts the notifications on cooldown until the [param cooldown_period] is elapsed.
func _on_low_stat_sounds_finished():
	on_cooldown = true
