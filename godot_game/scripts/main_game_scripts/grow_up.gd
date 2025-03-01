class_name GrowUpToAdult extends ScriptNode

@export var current_sprite: AnimatedSprite2D
@export var next_sprite: AnimatedSprite2D
@export var shader_area: ColorRect
@export var display_box: NinePatchRect

@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var mid_display_pos: Vector2 = display_box.global_position - (display_box.size * display_box.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var continue_btn: NinePatchRect = find_child("ContinueBtn")

var move_buffers: Array[FloatBuffer] = []

const SILLOUHETTE: Color = Color.BLACK

func _ready() -> void:
	Globals.perform_opening_transition(trans_img, mid_pos)
	mid_display_pos.y += 25


func start_grow_up():
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(-1, -1, .6, 1), 0.1, .5)
	Globals.tween(current_sprite, "modulate", SILLOUHETTE, .1, .5)
	tween_sprite_to_goal(current_sprite, mid_display_pos)
	next_sprite.modulate = SILLOUHETTE


func finish_grow_up():
	Globals.fire_confetti(%ConfettiLayer, Vector2(270, 440))
	
	continue_btn.visible = true
	continue_btn.modulate = Color(1, 1, 1, 0)
	var t = get_tree().create_tween()
	t.tween_property(continue_btn, "modulate", Color(1, 1, 1, 1), 1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(.5)
	
	%EggDesc.text = "[center][font_size=15]Your creature has grown up! Continue taking good care of it so it can keep growing!"


func tween_sprite_to_goal(sprite, goal: Vector2):
	var end_movement = func():
		move_buffers.clear()
	
	# move animation
	move_buffers = [FloatBuffer.new(sprite.global_position.x), FloatBuffer.new(sprite.global_position.y)]
	Globals.tween(move_buffers[0], "value", goal.x, 0., 1.)  # x pos to center
	Globals.tween(move_buffers[1], "value", goal.y - 50, 0., .6)  # up
	Globals.tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN).connect("finished", end_movement)  # down

func _process(_delta):
	# progress bar
	#if selected_egg_inx != null and !hatching:
		#update_selected_egg(delta)

	# move creature
	if move_buffers.size() > 0:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		current_sprite.global_position = new_p
		next_sprite.global_position = new_p

class FloatBuffer:
	var value: float = 0.
	func _init(v: float):
		value = v
