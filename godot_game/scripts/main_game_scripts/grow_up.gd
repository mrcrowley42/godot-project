class_name GrowUpToAdult extends ScriptNode

@export var creature_container: Node2D
@export var current_sprite: AnimatedSprite2D
@export var next_sprite: AnimatedSprite2D
@export var shader_area: ColorRect
@export var display_box: NinePatchRect

@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var mid_display_pos: Vector2 = display_box.global_position - (display_box.size * display_box.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var continue_btn: NinePatchRect = find_child("ContinueBtn")


func _ready() -> void:
	Globals.perform_opening_transition(trans_img, mid_pos)


func start_grow_up():
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(-1, -1, .8, 1), .0, 3)
	creature_container.do_start_tween()


func finish_grow_up():
	%FastTimer.stop()
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(.1, .2, .5, 1), .0, .5)
	Globals.fire_confetti(%ConfettiLayer, Vector2(270, 440))
	
	continue_btn.visible = true
	continue_btn.modulate = Color(1, 1, 1, 0)
	var t = get_tree().create_tween()
	t.tween_property(continue_btn, "modulate", Color(1, 1, 1, 1), 1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(.5)
	
	%EggDesc.text = "[center][font_size=15]Your creature has grown up! Continue taking good care of it so it can keep growing!"
