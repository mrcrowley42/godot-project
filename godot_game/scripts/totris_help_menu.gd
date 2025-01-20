extends Control

@export var simple_menu: Control
@export var adv_menu: Control
@export var adv_toggle_btn: Button

func _ready():
	reset()

func _on_visibility_changed():
	reset()

func _on_advanced_toggle_button_down():
	simple_menu.visible = !simple_menu.visible
	adv_menu.visible = !adv_menu.visible

func reset():
	adv_toggle_btn.button_pressed = false
	simple_menu.show()
	adv_menu.hide()
