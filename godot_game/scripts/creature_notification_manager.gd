@icon("res://icons/class-icons/bell-fill.svg")
extends Node

## Manages the visual and audio notifications for a Creature.
@export_category("Files")
@export_group("Sound Files")
@export var low_food: AudioStream
@export var low_fun: AudioStream
@export var low_hp: AudioStream
@export var low_water: AudioStream
@export_group("Image Files")
@export var low_food_img: Texture2D
@export var low_fun_img: Texture2D
@export var low_hp_img: Texture2D
@export var low_water_img: Texture2D

@export_category("Settings")
## How long (in seconds) after a sound effect has finished playing can another one begin.
@export var cooldown_period: float = 10.0
## How long (in seconds) a notification should last.
@export var notifcation_length: float = 0.0
## How low a stat has to be, relative to its maximum value to trigger a notifcation.
@export_range(0,1, 0.01) var warning_threshold: float = 0.2
## Whether audio notifcations should be disabled in clippy mode.
@export var mute_in_clippy :bool = true

@onready var notification_bubble = %NotificationBubble
@onready var notif_sounds = %LowStatSounds
@onready var notif = %Example
@onready var creature: Creature = $".."
@onready var notif_icon = %Icon
@onready var STAT = Creature.Stat
@onready var cooldown_timer = Timer.new()
@onready var water_threshold = warning_threshold * creature.max_water
@onready var food_threshold = warning_threshold * creature.max_food
@onready var fun_threshold = warning_threshold * creature.max_fun
@onready var hp_threshold = warning_threshold * creature.max_hp
@onready var reg_volume = notif_sounds.volume_db
@onready var stat_files = {STAT.HP: [low_hp, low_hp_img], STAT.WATER: [low_water, low_water_img],
	STAT.FOOD: [low_food, low_food_img], STAT.FUN: [low_fun, low_fun_img]}

## Bool to keep track whether notifications should still be on cooldown or not.
var on_cooldown: bool = false

func _ready() -> void:
	cooldown_timer.wait_time = cooldown_period
	cooldown_timer.timeout.connect(done)
	cooldown_timer.autostart = false
	cooldown_timer.name = "CooldownTimer"
	add_child(cooldown_timer)


func _process(_delta) -> void:
	notification_bubble.visible = notif_sounds.playing
	if on_cooldown:
		return
	var low_stats = []
	# This looks bad, but it's to catch multiple stats being low at a time.
	if creature.water <= water_threshold:
		low_stats.append(Creature.Stat.WATER)
	if creature.food <= food_threshold:
		low_stats.append(STAT.FOOD)
	if creature.fun <= fun_threshold:
		low_stats.append(STAT.FUN)
	if creature.hp <= hp_threshold:
		low_stats.append(STAT.HP)

	if low_stats.is_empty():
		return

	var picked_stat = low_stats.pick_random()
	queue_warning(stat_files[picked_stat][0])
	notif_icon.texture = stat_files[picked_stat][1]


func done() -> void:
	on_cooldown = false
	cooldown_timer.stop()


func queue_warning(sound_file: AudioStream) -> void:
	if not notif_sounds.playing and not on_cooldown:
		notif_sounds.stream = sound_file
		# A little scuffed, can probably do this better.
		if creature.clippy_area.clippy and mute_in_clippy:
			notif_sounds.volume_db = -100
		else:
			notif_sounds.volume_db = reg_volume
		notif_sounds.play()
	on_cooldown = true


## When a sound finishes, puts the notifications on cooldown until the [param cooldown_period] is elapsed.
func _on_low_stat_sounds_finished() -> void:
	on_cooldown = true
	cooldown_timer.start()
