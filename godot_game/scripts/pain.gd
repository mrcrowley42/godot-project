extends AudioStreamPlayer

@export var sounds: Array[AudioStream]

@onready var cooldown_timer = Timer.new()
## Bool to keep track whether notifications should still be on cooldown or not.
var on_cooldown: bool = false

func play_random() -> void:
	if not on_cooldown:
		print("htes")
		## Play random sound from [param sounds] pool.
		var audio = sounds.pick_random()
		self.stream = audio
		self.play()
		on_cooldown = true

func _ready() -> void:
	# TODO Update this when creature changes.
	cooldown_timer.wait_time = 1
	cooldown_timer.timeout.connect(done)
	cooldown_timer.autostart = false
	cooldown_timer.name = "CooldownTimer"
	add_child(cooldown_timer)

func done() -> void:
	on_cooldown = false
	cooldown_timer.stop()

func _on_finished() -> void:
	on_cooldown = true
	cooldown_timer.start()
