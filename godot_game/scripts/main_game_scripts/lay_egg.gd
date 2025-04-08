class_name LayEggScene extends ScriptNode

@export var back_btn: NinePatchRect
@export var next_btn: NinePatchRect
@export var continue_btn: NinePatchRect
@export var display_box: NinePatchRect
@export var dialog_box: RichTextLabel
@export var creature: Node2D
@export var creature_sprite: AnimatedSprite2D
@export var egg: Node2D
@export var egg_sprite: Sprite2D
@export var egg_collision: Area2D
@export var shader_area: ColorRect

@export var all_eggs: EggList

@onready var bg: NinePatchRect = find_child("BG")
@onready var mid_pos: Vector2 = bg.position + (bg.size * bg.scale) * .5
@onready var mid_display_pos: Vector2 = display_box.global_position - (display_box.size * display_box.scale) * .5
@onready var trans_img: Sprite2D = find_child("Transition")

const INVISIBLE = Color(1, 1, 1, 0)
const DISABLED = Color(1, 1, 1, .4)
const DEFAULT = Color(1, 1, 1, 1)
const MOVEMENT_TIME: float = 1;

var dialog_page = 0
var DIALIDG_TREE = []

var creature_name = ""
var back_disabled = true
var next_disabled = false
var continue_disabled = true
var egg_disabled = true
var has_walked_away = false
var egg_pressed = false
var egg_bobbing = false

var bounce_mov_og_pos: Vector2
var bounce_movement_start: float = 0.
var walk_mov_og_y: float = 0.
var walk_movement_start: float = 0.
var move_sprite: Node = null
var move_buffers: Array[FloatBuffer] = []
var egg_og_pos: Vector2

var chosen_egg: EggEntry = null

const BASE_EGG_SCALE: Vector2 = Vector2(1, 1)
const HOVER_SELECTED_EGG_ADDITION: Vector2 = Vector2(.2, .2)
var egg_scale_add = Vector2(0, 0)

func _ready() -> void:
	creature_name = Globals.general_dict["creature_name"]
	Globals.general_dict.erase("creature_name")
	
	DIALIDG_TREE = [
		"You're creature, %s, has grown so much!" % creature_name,
		"You've taken care of %s from the moment it hatched from its egg." % creature_name,
		"You've seen %s learn and grow, through happy times and times of hardship." % creature_name,
		"%s has tried food it loves... and food it doesn't really like." % creature_name,
		"%s has played many games with you and has learnt the value of friendship." % creature_name,
		"%s loves trying on different accessories, and chilling out to soft ambience." % creature_name,
		"But %s is an adult now." % creature_name,
		"And its able to use the valuable experience and knowledge its gained to continue on its own.",
		"%s will miss you, it won't ever forget this journey." % creature_name,
		"%s is ready to become independent, and continue its adventure into new and unexplored territory." % creature_name,
		"Are you ready for a new journey as well?"
	]
	
	Globals.perform_opening_transition(trans_img, mid_pos)
	update_dialog()
	
	## pick from pool of eggs that havent been hatched before
	var hatched_eggs = DataGlobals.get_global_metadata_value(DataGlobals.HATCHED_EGGS)
	var egg_choices = all_eggs.items
	for egg_c in egg_choices:
		var uid = Helpers.uid_str(egg_c)
		if uid in hatched_eggs:
			egg_choices.erase(egg_c)
	if len(egg_choices) == 0:  # all eggs have been hatched true random
		egg_choices = all_eggs.items
	chosen_egg = egg_choices.pick_random()
	egg_sprite.texture = chosen_egg.image

func update_dialog(dialog_addition: int = 0):
	dialog_page = max(0, min(len(DIALIDG_TREE) - 1, dialog_page + dialog_addition))
	dialog_box.text = "[center]%s" % DIALIDG_TREE[dialog_page]
	
	back_disabled = dialog_page == 0
	next_disabled = dialog_page == len(DIALIDG_TREE) - 1
	continue_disabled = !next_disabled
	
	back_btn.modulate = DISABLED if back_disabled else DEFAULT
	next_btn.modulate = DISABLED if next_disabled else DEFAULT
	continue_btn.modulate = DISABLED if continue_disabled else DEFAULT
	
	if dialog_addition != 0:
		%SFX.play_sound("click")

func play_walk_away_animation():
	Globals.tween(creature, 'scale', Vector2(.8, .8), 0.1, .5, Tween.EASE_IN)
	await tween_sprite_to_goal(creature, creature.global_position, creature.global_position + Vector2(0, -20)).finished
	await get_tree().create_timer(.3).timeout
	await creature_sprite.frame_changed
	
	creature_sprite.animation = 'joy' if creature_sprite.sprite_frames.has_animation('joy') else (
		'happy' if creature_sprite.sprite_frames.has_animation('happy') else 'chill'
	)
	bounce_movement_start = Time.get_unix_time_from_system()
	bounce_mov_og_pos = creature.position
	
	await get_tree().create_timer(MOVEMENT_TIME + .3).timeout
	walk_movement_start = Time.get_unix_time_from_system()
	walk_mov_og_y = creature_sprite.position.y
	Globals.tween(creature, 'position', Vector2(-400, creature.position.y), 0., 3., Tween.EASE_IN, Tween.TRANS_CUBIC)
	
	await get_tree().create_timer(1.5).timeout
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(-1, -1, .8, 1), .0, 3)
	
	await get_tree().create_timer(2.).timeout
	dialog_box.text = '[center]Wait... It looks like %s left something behind.' % creature_name
	has_walked_away = true
	continue_btn.modulate = DEFAULT
	continue_disabled = false

func play_find_egg_animation():
	Globals.tween(shader_area.material, "shader_parameter/offset", Vector2(-1, 0), .0, 3, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	Globals.tween(shader_area.material, "shader_parameter/scale", .6, .0, 3, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	Globals.tween(egg, "position", Vector2(mid_display_pos.x, egg.position.y), .0, 3, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	await Globals.tween(egg, "scale", Vector2(1., 1.), .0, 3, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC).finished
	egg_disabled = false

func play_select_egg_animation():
	Globals.tween(shader_area.material, "shader_parameter/color", Vector4(0, .2, 0, 1), .0, 3)
	Globals.tween(egg, 'scale', Vector2(2., 2.), 0.1, .5, Tween.EASE_IN)
	Globals.tween(egg_sprite, 'modulate', Color(1, 1, 1, 1), 0.1, .5, Tween.EASE_IN)
	await tween_sprite_to_goal(egg, egg.global_position, egg.global_position + Vector2(0, 10)).finished
	egg_og_pos = egg_sprite.position
	egg_bobbing = true
	
	dialog_box.text = '[center]%s left you a %s as a gift!' % [creature_name, chosen_egg.name]
	continue_btn.modulate = DEFAULT
	continue_disabled = false


func _on_back_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not back_disabled:
		update_dialog(-1)

func _on_next_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not next_disabled:
		update_dialog(1)

func _on_continue_btn_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not continue_disabled:
		if not has_walked_away:
			next_disabled = true
			back_disabled = true
			continue_disabled = true
			dialog_box.text = "[center]..."
			
			next_btn.modulate = INVISIBLE
			back_btn.modulate = INVISIBLE
			continue_btn.modulate = INVISIBLE
			play_walk_away_animation()
		elif not egg_pressed:
			dialog_box.text = "[center]..."
			continue_btn.modulate = INVISIBLE
			continue_disabled = true
			play_find_egg_animation()
			
			DataGlobals.set_metadata_value(false, DataGlobals.CREATURE_IS_INDEPENDENT, true)
			DataGlobals.add_pending_egg(chosen_egg, DataGlobals.get_global_metadata_value(DataGlobals.CURRENT_CREATURE))
		else:
			DataGlobals.set_metadata_value(true, DataGlobals.CURRENT_CREATURE, "-1")
			await Globals.perform_closing_transition(trans_img, mid_pos)
			Globals.change_to_scene("res://scenes/GameScenes/main_menu.tscn")

func tween_sprite_to_goal(sprite: Node, start_pos: Vector2, goal: Vector2) -> Tween:
	var end_movement = func():
		move_buffers.clear()
		move_sprite = null
	
	# move animation
	move_sprite = sprite
	move_buffers = [FloatBuffer.new(start_pos.x), FloatBuffer.new(start_pos.y)]
	Globals.tween(move_buffers[0], "value", goal.x, 0., 1.)  # x pos to center
	Globals.tween(move_buffers[1], "value", goal.y - 50, 0., .6)  # up
	var t = Globals.tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN)
	t.connect("finished", end_movement)  # down
	return t

func _process(_delta):
	if not egg_pressed:
		egg.scale = BASE_EGG_SCALE + egg_scale_add
	elif egg_bobbing:
		var s = sin(Time.get_unix_time_from_system()) * 6
		egg_sprite.position.y = egg_og_pos.y + s
	
	if move_buffers.size() > 0:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		move_sprite.global_position = new_p
	
	var bounce_t = Time.get_unix_time_from_system() - bounce_movement_start
	if bounce_t < MOVEMENT_TIME:
		var inv_percent = 1-(bounce_t / MOVEMENT_TIME)
		creature.position.y = bounce_mov_og_pos.y + (-abs(sin(bounce_t * 8)) * 35) * inv_percent
	
	var walk_t = Time.get_unix_time_from_system() - walk_movement_start
	if walk_t < 100:
		creature_sprite.position.y = walk_mov_og_y + (-abs(sin(walk_t * 8)) * 13) * min(walk_t, 1)

class FloatBuffer:
	var value: float = 0.
	func _init(v: float):
		value = v


func _on_egg_area_mouse_entered() -> void:
	if not egg_pressed:
		dialog_box.text = '[center]Unknown egg'
		Globals.tween(self, "egg_scale_add", HOVER_SELECTED_EGG_ADDITION, 0., .5)


func _on_egg_area_mouse_exited() -> void:
	if not egg_pressed:
		dialog_box.text = '[center]...'
		Globals.tween(self, "egg_scale_add", Vector2(0., 0.), 0., .5)


func _on_egg_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_pressed() and not egg_disabled:
		egg_pressed = true
		egg_disabled = true
		dialog_box.text = '[center]...'
		play_select_egg_animation()
