class_name NotificationAdv extends Control

@export var btm_right: Vector2
@export var margin: Vector2

@export var message: String
@export var icon: Texture2D
## in seconds
@export var lifetime: int

@export var button: Button
@export var label: Label


func _ready() -> void:
	label.text = message
	button.icon = icon
	
	position = btm_right


func tween_in() -> void:
	pass


func tween_up() -> void:
	pass
