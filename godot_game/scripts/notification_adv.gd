class_name NotificationAdv extends Control

signal removed

@export var btm_right: Vector2
@export var message: String
@export var icon: Texture2D
@export var button: Button
@export var label: Label

## in seconds
const lifetime: int = 5
var margin: Vector2 = Vector2(20, 10)
var noti_slot: int

func _ready() -> void:
	label.text = message
	button.icon = icon
	position = btm_right + Vector2(margin.x, -size.y)

func tween_in(slot: int) -> void:
	noti_slot = slot
	position.y -= (size.y + margin.y) * slot
	var to: Vector2 = position
	to.x -= size.x + margin.x
	Globals.tween(self, "position", to, 0.0, 1.0)
	
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = lifetime
	timer.timeout.connect(tween_out)
	add_child(timer)

func tween_out() -> void:
	await Globals.tween(self, "modulate", Color(1., 1., 1., 0.), 0.0, .5).finished
	removed.emit(noti_slot)

func _on_button_2_button_down():
	tween_out()
