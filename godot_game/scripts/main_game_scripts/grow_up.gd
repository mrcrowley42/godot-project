class_name GrowUpToAdult extends ScriptNode

@export var creature_container: Node2D
@export var current_sprite: AnimatedSprite2D
@export var next_sprite: AnimatedSprite2D
@export var shader_area: ColorRect
@export var display_box: NinePatchRect
@export var progress_bar_container: Control
@export var bar: ProgressBar
@export var bar_progress_color: Gradient
@export var area2d: Area2D

@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var mid_display_pos: Vector2 = display_box.global_position - (display_box.size * display_box.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var continue_btn: NinePatchRect = find_child("ContinueBtn")

var rotation_buffer: FloatBuffer = FloatBuffer.new(0.)
var move_buffers: Array[FloatBuffer] = []
var can_area_interact: bool = false
var mouse_in_area: bool = false

const DEFAULT_SCALE := Vector2(.225, .225)
const MAX_SCALE := Vector2(.35, .35)
const HOVER_SCALE_ADDITION := Vector2(.02, .02)
const BAR_CLICK_ADDITION: int = 100
const BAR_DRAIN_AMOUNT: int = 200

const SILLOUHETTE: Color = Color.BLACK

var scale_addition: Vector2 = Vector2(0, 0)
var last_clicked = 0

func _ready() -> void:
	Globals.perform_opening_transition(trans_img, mid_pos)
	progress_bar_container.modulate.a = 0

func set_can_area_interact(val):
	can_area_interact = val
	hover_over_creature()

func start_grow_up():
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(-1, -1, .6, 1), 0.1, .5)
	Globals.tween(current_sprite, "modulate", SILLOUHETTE, .1, .5)
	next_sprite.modulate = SILLOUHETTE
	tween_sprite_to_goal(current_sprite, mid_display_pos).connect("finished", set_can_area_interact.bind(true))
	Globals.tween(progress_bar_container, "modulate", Color(1, 1, 1, 1), .0, .5)


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


func tween_sprite_to_goal(sprite, goal: Vector2) -> Tween:
	var end_movement = func():
		move_buffers.clear()
	
	# move animation
	move_buffers = [FloatBuffer.new(sprite.global_position.x), FloatBuffer.new(sprite.global_position.y)]
	Globals.tween(move_buffers[0], "value", goal.x, 0., 1.)  # x pos to center
	Globals.tween(move_buffers[1], "value", goal.y - 50, 0., .6)  # up
	var t = Globals.tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN)
	t.connect("finished", end_movement)  # down
	return t

func _process(delta):
	# progress bar
	if can_area_interact:
		update_creature_progress(delta)

	# move creature
	if move_buffers.size() > 0:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		current_sprite.global_position = new_p
		next_sprite.global_position = new_p

class FloatBuffer:
	var value: float = 0.
	func _init(v: float):
		value = v

func hover_over_creature():
	if can_area_interact:
		if mouse_in_area:
			Globals.tween(self, "scale_addition", HOVER_SCALE_ADDITION, 0., .5)
		else:
			Globals.tween(self, "scale_addition", Vector2(0, 0), 0., .5)

func update_creature_progress(delta):
	var next_visible = (Time.get_unix_time_from_system() - last_clicked) < .3
	current_sprite.visible = !next_visible
	next_sprite.visible = next_visible
	
	# bar
	var percent: float = bar.value / bar.max_value
	bar.value -= BAR_DRAIN_AMOUNT * delta
	bar["theme_override_styles/fill"].bg_color = bar_progress_color.sample(percent)
	
	# scale
	var scale = DEFAULT_SCALE + (MAX_SCALE - DEFAULT_SCALE) * percent
	current_sprite.scale = scale
	current_sprite.scale += scale_addition  # for mouse hovering
	next_sprite.scale = scale
	next_sprite.scale += scale_addition

	# rotation
	if can_area_interact:
		var freq = Time.get_unix_time_from_system() * 15 + (10 * percent)
		var amp = .08 + (.08 * percent)  # additions are for randomness
		creature_container.rotation = (sin(freq) * amp) * rotation_buffer.value

func _on_area_2d_mouse_entered():
	mouse_in_area = true
	hover_over_creature()

func _on_area_2d_mouse_exited():
	mouse_in_area = false
	hover_over_creature()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if can_area_interact and event.is_pressed():
		last_clicked = Time.get_unix_time_from_system()
		bar.value += BAR_CLICK_ADDITION
		
		# rotation
		Globals.tween(rotation_buffer, "value", 1, 0., .1, Tween.EASE_IN_OUT)  # tween to 1
		Globals.tween(rotation_buffer, "value", 0, 0.1, .4, Tween.EASE_IN_OUT)  # tween to 0
		
		# sound
		%SFX.pitch_scale = .5 + 2 * (bar.value / bar.max_value)
		%SFX.play_sound("pop")
