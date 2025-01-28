class_name MainMenu extends ScriptNode

@onready var load_menu = find_child("LoadMenu")

@onready var bg_gradient: TextureRect = find_child("BgGradient")
@onready var trans_img: Sprite2D = find_child("Transition")

var center_pos
var is_in_transition = true

func _ready() -> void:
	center_pos = bg_gradient.size / 2
	do_opening_trans()


func do_opening_trans():
	Globals.perform_opening_transition(trans_img, center_pos, set_is_in_trans.bind(false))

func do_closing_trans():
	set_is_in_trans(true)
	return await Globals.perform_closing_transition(trans_img, center_pos)

func set_is_in_trans(value: bool):
	is_in_transition = value


func _on_quit_btn_button_down() -> void:
	if not is_in_transition:
		get_tree().quit()


func _on_continue_btn_button_down() -> void:
	if not is_in_transition:
		await do_closing_trans()
		Globals.change_to_scene("res://scenes/GameScenes/main.tscn")


func _on_new_game_btn_button_down() -> void:
	if not is_in_transition:
		await do_closing_trans()
		Globals.change_to_scene("res://scenes/GameScenes/egg_opening.tscn")


func _on_load_btn_button_down() -> void:
	if not is_in_transition:
		load_menu.show()
	#pass # Replace with function body.
