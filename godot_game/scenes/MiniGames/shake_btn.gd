extends Button

@export var shake_rate: int = 4
@export var shake_amount:int = 1
@onready var shake_timer: Timer = Timer.new()
@onready var init_pos: Vector2 = position

func _ready() -> void:
	shake_timer.autostart = true
	shake_timer.wait_time = 1.0 / shake_rate
	add_child(shake_timer)
	shake_timer.connect("timeout", _on_shake_timer_timeout)
	
func shake() -> void:
	position = init_pos + Vector2(random_offset(), random_offset())

func _on_shake_timer_timeout() -> void:
	shake()

func random_offset() -> int:
	return randi_range(-shake_amount, shake_amount)
