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

@onready var notification_bubble = %NotificationBubble
@onready var notif_sounds = %LowStatSounds
@onready var notif = %Example
@onready var creature: Creature = $".."
@onready var notif_icon = %Icon
@onready var STAT = Creature.Stat
@onready var cooldown_timer = Timer.new()
@onready var water_threshold = 0
@onready var food_threshold = 0
@onready var fun_threshold = 0
@onready var hp_threshold = 0
@onready var reg_volume = notif_sounds.volume_db
@onready var pain_threshold = 0
@onready var stat_files = {STAT.HP: [low_hp, low_hp_img], STAT.WATER: [low_water, low_water_img],
	STAT.FOOD: [low_food, low_food_img], STAT.FUN: [low_fun, low_fun_img]}

## Bool to keep track whether notifications should still be on cooldown or not.
var on_cooldown: bool = false

var notifications_enabled = true

func _ready() -> void:
	# TODO Update this when creature changes.
	cooldown_timer.wait_time = cooldown_period
	cooldown_timer.timeout.connect(done)
	cooldown_timer.autostart = false
	cooldown_timer.name = "CooldownTimer"
	add_child(cooldown_timer)
	creature.hp_changed.connect(check_status)
	creature.food_changed.connect(check_status)
	creature.water_changed.connect(check_status)
	creature.fun_changed.connect(check_status)

func _notification(noti: int) -> void:
	if noti == Globals.NOTIFICATION_CREATURE_IS_LOADED:
		if not creature.creature:
			notifications_enabled = false
			return
		notification_bubble.position = creature.creature.notification_position
		pain_threshold = warning_threshold / 2 * creature.max_hp
		water_threshold = warning_threshold * creature.max_water
		food_threshold = warning_threshold * creature.max_food
		fun_threshold = warning_threshold * creature.max_fun
		hp_threshold = warning_threshold * creature.max_hp

func _process(_delta) -> void:
	if not notifications_enabled:
		return
	
	if creature.hp <= pain_threshold:
		%STAHP.play_random()
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
	check_status()
	notif_icon.texture = stat_files[picked_stat][1]


func done() -> void:
	on_cooldown = false
	cooldown_timer.stop()


func queue_warning(sound_file: AudioStream) -> void:
	if not notifications_enabled:
		return
	
	if not notif_sounds.playing and not on_cooldown:
		notif_sounds.stream = sound_file
		if creature.clippy_area.mute_sfx:
			return
		notif_sounds.play()
	on_cooldown = true


## When a sound finishes, puts the notifications on cooldown until the [param cooldown_period] is elapsed.
func _on_low_stat_sounds_finished() -> void:
	on_cooldown = true
	cooldown_timer.start()

func get_emotion():
	if creature.zen:
		return "chill" if creature.main_sprite.sprite_frames.has_animation("chill") else "joy"
	
	if creature.hp <= hp_threshold:
		return 'sad'
	if creature.water <= water_threshold:
		return 'confused'
	if creature.food <= food_threshold:
		return 'confused'
	if creature.fun <= fun_threshold:
		return 'angry'
	
	return 'idle'

func check_status():
	var anim = get_emotion()
	# wait manually to make sure creature movements are correctly accounted for
	@warning_ignore("redundant_await")  # its not redundant bruh
	await creature.main_sprite.frame_changed
	if anim and creature.current_movement == creature.Movement.NOTHING:
		creature.force_change_animation(anim)
	
