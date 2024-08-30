class_name EggOpen extends ScriptNode

@export var skip_scene: bool = false
@export var existing_eggs: Array[EggEntry]
@export var egg_cracks: Array[Texture2D]
@export var egg_alpha_map: Texture2D  # trust me bro
@export var bar_progress_color: Gradient

@export_subgroup("limit egg selection")
@export var choices_start_inx: int = 0
@export var choices_amnt: int = 3;
@export var limit_to_one: bool = false
@export var egg_index: int
@export var limit_to_many: bool = false
@export var egg_indexes: Array[int]

@onready var bg: NinePatchRect = find_child("BG")
@onready var trans_img: Sprite2D = find_child("Transition")
@onready var title_container: Control = find_child("TitleContainer")
@onready var selection_title: RichTextLabel = find_child("SelectTitle")
@onready var selection_area: Control = find_child("SelectionArea")
@onready var shader_area: ColorRect = find_child("shader")
@onready var egg_desc: RichTextLabel = find_child("EggDesc")
@onready var back_btn: NinePatchRect = find_child("BackButton")
@onready var continue_btn: NinePatchRect = find_child("ContinueButton")
@onready var bar_container: Control = find_child("EggBarContainer")
@onready var bar: ProgressBar = find_child("Bar")
@onready var display_box: NinePatchRect = find_child("DisplayBox")
@onready var display_bg: ColorRect = find_child("whiteBg")
@onready var display_shader: ColorRect = find_child("shader")
@onready var hatch_timer: Timer = find_child("HatchTimer")
@onready var example_creature: AnimatedSprite2D = find_child("ExampleCreature")

@onready var alpha_shader = preload("res://shaders/apply_alpha_map.gdshader")
@onready var alpha_map = preload("res://images/egg/egg-alpha-map.png")

const BAR_CLICK_ADDITION: int = 100
const BAR_DRAIN_AMOUNT: int = 200
const EPSILON: float = 0.0001
const STRING_SELECT_YOUR_EGG: String = "Select your egg"
const NO_EGG_FORMAT_STRING: String = "[center]%s"
const EGG_FORMAT_STRING: String = "[center][u]%s[/u]\nHatches: %s"

const SMALL_EGG_SCALE: Vector2 = Vector2(1.5, 1.5)
const BASE_EGG_SCALE: Vector2 = Vector2(1.8, 1.8)
const HOVER_EGG_SCALE: Vector2 = Vector2(2., 2.)
const BASE_SELECTED_EGG_SCALE: Vector2 = Vector2(2.2, 2.2)
const MAX_SELECTED_EGG_SCALE: Vector2 = Vector2(3, 3)
const HOVER_SELECTED_EGG_ADDITION: Vector2 = Vector2(.2, .2)

var selection_area_center: Vector2
var select_title_text: String
var move_buffers: Array[FloatBuffer] = []
var rotation_buffer: FloatBuffer = FloatBuffer.new(0.)
var can_interact: bool = false  # turn off while tweening stuff around
var hatching: bool = false
var finished_hatching: bool = false
var hatch_progress: int = 0

var placed_eggs: Array[EggEntry] = []
var placed_egg_sprites: Array[Control] = []
var original_egg_positions: Array[Vector2] = []
var selected_egg_inx = null  # int
var scale_addition: Vector2 = Vector2(0, 0)

func _ready():
	if skip_scene:
		load_main_scene()
		return
	
	# setup
	bar_container.visible = false
	continue_btn.visible = false
	back_btn.visible = false
	back_btn.connect("gui_input", back_btn_input)
	select_title_text = selection_title.text
	selection_title.text = select_title_text % [STRING_SELECT_YOUR_EGG]
	
	# transition
	trans_img.position = bg.position + (bg.size * bg.scale) * .5
	tween(trans_img, "position", trans_img.position + Vector2(0, 1000), .5, 1.5)
	
	# eggs
	selection_area_center = selection_area.position + selection_area.size * .5
	spawn_eggs()

func load_main_scene():
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/GameScenes/main.tscn")

## structure of egg:
## - Control  (scale & move this, rotate for centeral rotation)
##   - Control  (top)
##     - Sprite2D
##     - <egg crack Sprite2D's>
##   - Control  (bottom)
##     - Sprite2D
##     - <egg crack Sprite2D's>
##   - Area2D  (mouse detection)
##     - CollisionShape2D
func spawn_eggs():
	# find the eggs to be placed
	var eggs_to_place: Array[EggEntry] = existing_eggs.slice(choices_start_inx, choices_start_inx + choices_amnt)
	if limit_to_one:
		eggs_to_place = [existing_eggs[egg_index]]
	if limit_to_many:
		eggs_to_place = []
		for i: int in egg_indexes:
			eggs_to_place.append(existing_eggs[i])
	
	# placement values
	var middle_pos = selection_area.position + Vector2(0, selection_area.size.y * .5)
	var scalar: float = selection_area.size.x * (1. / eggs_to_place.size())
	
	# place each egg evenly & animate them
	for i: int in eggs_to_place.size():
		var egg: EggEntry = eggs_to_place[i]
		var sprite_c: Control = Control.new()
		sprite_c.name = "egg-%s" % [i]
		
		# add top and bottom images of egg
		for x: int in 2:
			var c: Control = Control.new()
			var sprite: Sprite2D = Sprite2D.new()
			c.name = "top" if !x else "bottom"
			sprite.texture = egg.image
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # sharp image
			add_alpha_mask(sprite, x)
			c.add_child(sprite)
			sprite_c.add_child(c)
		
		# set default values
		var x_pos = scalar * i
		x_pos += scalar * .5  # center the eggs
		sprite_c.modulate.a = 0.
		sprite_c.position = middle_pos + Vector2(x_pos, 0)
		sprite_c.scale = SMALL_EGG_SCALE
		original_egg_positions.append(sprite_c.position)
		
		# initialising
		add_child(sprite_c)
		add_collision_areas(sprite_c, i)
		do_opening_animation(sprite_c, i, i == eggs_to_place.size() - 1)
		
		placed_egg_sprites.append(sprite_c)
	placed_eggs = eggs_to_place

## add alpha mask shader to obj and its normal is decided by given x
func add_alpha_mask(obj, x: int):
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = alpha_shader
	obj.material = mat
	obj.material["shader_parameter/normal"] = Vector2(1 - x, x);
	obj.material["shader_parameter/alpha_map"] = alpha_map;

## add to each egg as it is spawned
func add_collision_areas(sprite_cl: Control, i: int):
	var area_2d: Area2D = Area2D.new()
	var coll_shape: CollisionShape2D = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	
	sprite_cl.add_child(area_2d)
	area_2d.add_child(coll_shape)
	area_2d.monitorable = false  # not nessecary
	circle.radius = 25  # close enough to the eggs size
	coll_shape.shape = circle
	
	# setup mouse events
	area_2d.connect("mouse_entered", mouse_entered.bind(i))
	area_2d.connect("mouse_exited", mouse_exited.bind(i))
	area_2d.connect("input_event", mouse_clicked.bind(i))

## call for each egg as it is spawned
func do_opening_animation(sprite_c: Control, i: int, is_last_egg: bool):
	var diff = .2 * i
	tween(sprite_c, "modulate", Color.WHITE, 1. + diff, .5, Tween.EASE_IN_OUT)  # fade in
	tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y - 20), 1.2 + diff, .6)  # move up
	var move_down_tween = tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y), 1.4 + diff, .4, Tween.EASE_IN)  # move down
	if is_last_egg:
		move_down_tween.connect("finished", end_opening_animation)

## called automatically
func end_opening_animation():
	# scale all placed eggs up
	for i: int in placed_egg_sprites.size():
		var scale_tween = scale_egg(i, BASE_EGG_SCALE)
		if i == placed_eggs.size() - 1:  # only on the last egg
			scale_tween.connect("finished", manual_mouse_check)

## generic tween function
func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_OUT):
	var t = get_tree().create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

## check if mouse is within an egg and call event if so
func manual_mouse_check(sprite_c: Control = null):
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	set_can_interact(true)
	
	var is_mouse_within = func(s: Control) -> bool:
		var dist: float = (mouse_pos - s.position).length()
		var area: Area2D = s.get_child(-1)
		var radius: float = area.get_child(0).shape.radius * (s.scale.x * .9)  # scale area down just a little
		return dist < radius
	
	if sprite_c == null:  # check placed eggs
		for i: int in placed_egg_sprites.size():
			if (is_mouse_within.call(placed_egg_sprites[i])):
				mouse_entered(i)
	elif is_mouse_within.call(sprite_c):  # check selected egg
		mouse_entered(selected_egg_inx)

func set_can_interact(val: bool):
	can_interact = val

func mouse_entered(i: int):
	if can_interact and !finished_hatching:
		if selected_egg_inx == null:  # entered a placed egg
			scale_egg(i, HOVER_EGG_SCALE)
			set_egg_desc(i)
		elif i == selected_egg_inx:  # entered selected egg
			tween(self, "scale_addition", HOVER_SELECTED_EGG_ADDITION, 0., .5)

func mouse_exited(i: int):
	if can_interact and !finished_hatching:
		if selected_egg_inx == null:  # exited a placed egg
			scale_egg(i, BASE_EGG_SCALE)
			set_egg_desc()
			manual_mouse_check()  # in case there are overlapping eggs
		elif i == selected_egg_inx:  # exited selected egg
			tween(self, "scale_addition", Vector2(0, 0), 0., .5)

func mouse_clicked(_viewport, event: InputEvent, _shape_idx, i):
	if can_interact and event.is_pressed() and !finished_hatching:
		if selected_egg_inx == null:
			select_egg(placed_eggs[i], i)
		elif i == selected_egg_inx:
			click_selected_egg()

## when hovering over a placed egg
func set_egg_desc(i: int = -1):
	if i < 0:
		egg_desc.text = NO_EGG_FORMAT_STRING % ["..."]
		return
	
	var egg: EggEntry = placed_eggs[i]
	egg_desc.text = EGG_FORMAT_STRING % [egg.name, "???"]

## when one egg is selected from placed eggs
func select_egg(egg: EggEntry, inx: int):
	can_interact = false
	selected_egg_inx = inx
	
	# set labels
	selection_title.text = select_title_text % [egg.name]
	egg_desc.text = ""
	bar.value = 0  # reset
	fade(back_btn)
	fade(bar_container)
	
	# shader
	tween(shader_area.material, "shader_parameter/color", Vector4(0, 0, 1, 1), 0., 1., Tween.EASE_IN_OUT)
	tween_sprite_to_goal(selection_area_center)  # move selected to center
	
	# fade out other eggs
	for i: int in placed_egg_sprites.size():
		if i != inx:
			var sprite_c: Control = placed_egg_sprites[i]
			tween(sprite_c, "modulate", Color(1, 1, 1, 0), 0., .4)  # fade out
			tween(sprite_c, "position", Vector2(sprite_c.position.x, sprite_c.position.y + 20), 0., .3)  # move down

func hatch_egg():
	var sprite_c: Control = placed_egg_sprites[selected_egg_inx]
	set_can_interact(false)
	hatching = true
	
	# fade stuff out
	fade(title_container, false)
	fade(back_btn, false)
	fade(bar_container, false)
	set_egg_desc()  # "..."
	
	# scale display box
	var addition = Vector2(0, 240)
	tween(display_box, "size", display_box.size + addition, 0.1, .5)
	tween(display_bg, "size", display_bg.size + addition, 0.1, .5)
	tween(display_shader, "size", display_shader.size + addition, 0.1, .5)
	tween(shader_area.material, "shader_parameter/color", Vector4(0, 0, 0, 1), 0.1, .5)
	
	# move egg
	sprite_c.rotation = 0
	tween(sprite_c, "position", sprite_c.position - addition * .25, .1, .5)
	
	# timer
	hatch_timer.start()
	hatch_timer.connect("timeout", progress_hatching)

## 3 progressions & then finish
func progress_hatching():
	hatch_progress += 1
	var sprite_c: Control = placed_egg_sprites[selected_egg_inx]
	
	if hatch_progress == 4:
		finish_hatching(sprite_c)
		return
	
	# add top & bottom crack image to top & bottom egg Controls
	for i: int in 2:
		var c: Control = sprite_c.get_child(i)  # 0 = top, 1 = bottom
		var crack_sprite: Sprite2D = Sprite2D.new()
		crack_sprite.texture = egg_cracks[hatch_progress - 1]
		crack_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_alpha_mask(crack_sprite, i)
		c.add_child(crack_sprite)
	
	# egg scale
	var scale_add = Vector2(.2, .2) + Vector2(.1, .1) * hatch_progress
	sprite_c.scale = MAX_SELECTED_EGG_SCALE + scale_add
	scale_egg(selected_egg_inx, MAX_SELECTED_EGG_SCALE + (scale_add * .5))
	
	# egg rotation
	rotation_buffer.value = 1.
	tween(rotation_buffer, "value", 0, 0., .4, Tween.EASE_IN_OUT)  # tween to 0

func finish_hatching(sprite_c: Control):
	var connect_continue_input = func():  # so no accidently skipping creature reveal
		continue_btn.connect("gui_input", continue_btn_input)
	
	set_can_interact(true)
	finished_hatching = true
	hatch_timer.stop()
	egg_desc.text = "[center][u]Some Creature!"
	fade(continue_btn).connect("finished", connect_continue_input)
	
	# last scale
	var scale_add = Vector2(.2, .2) + Vector2(.1, .1) * hatch_progress
	sprite_c.scale = MAX_SELECTED_EGG_SCALE + scale_add
	scale_egg(selected_egg_inx, MAX_SELECTED_EGG_SCALE + (scale_add * .5))
	
	# open egg
	var top: Control = sprite_c.get_child(0)
	var bottom: Control = sprite_c.get_child(1)
	var speed = .5
	tween(top, "position", top.position + Vector2(0, -15), .0, speed)
	tween(top, "rotation", -.1, .0, speed)
	tween(bottom, "position", bottom.position + Vector2(0, 15), .0, speed)
	tween(bottom, "rotation", .1, .0, speed)
	fade(top, false, .3)
	fade(bottom, false, .3)
	
	# spawn creature
	example_creature.position = sprite_c.position + Vector2(0, -35)  # offset (may need to be different for each creature)
	fade(example_creature, true)
	tween(example_creature, "scale", Vector2(.25, .25), .3, .5)

## transition out & load main scene
func continue_btn_input(event: InputEvent):
	if can_interact and event.is_pressed():
		trans_img.rotation = PI
		trans_img.position.y = -1000
		tween(trans_img, "position", bg.position + (bg.size * bg.scale) * .5, 0., 1.).connect("finished", load_main_scene)

## generic scale of egg
func scale_egg(inx: int, to_scale: Vector2, time: float = .5):
	var sprite_c: Control = placed_egg_sprites[inx]
	return tween(sprite_c, "scale", to_scale, 0., time)

## generic fade in or out
func fade(obj, fade_in: bool = true, delay: float = 0.):
	if fade_in:
		obj.visible = true
		obj.modulate.a = 0
	var col = Color.WHITE if fade_in else Color(1, 1, 1, 0)
	var time = 1.0 if fade_in else .5
	var _ease = Tween.EASE_IN_OUT if fade_in else Tween.EASE_OUT
	return tween(obj, "modulate", col, delay, time, _ease)

func de_select_egg():
	selected_egg_inx = null
	set_egg_desc()
	manual_mouse_check()  # do check on all placed eggs

func click_selected_egg():
	bar.value += BAR_CLICK_ADDITION
	
	# rotation
	tween(rotation_buffer, "value", 1, 0., .1, Tween.EASE_IN_OUT)  # tween to 1
	tween(rotation_buffer, "value", 0, 0.1, .4, Tween.EASE_IN_OUT)  # tween to 0
	
	# hatch!
	if bar.value == bar.max_value:
		hatch_egg()

func tween_sprite_to_goal(goal: Vector2, scale_goal: Vector2 = BASE_SELECTED_EGG_SCALE, end_selection: bool = false):
	var end_movement = func(sp: Control):
		move_buffers.clear()
		de_select_egg() if end_selection else manual_mouse_check(sp)
	
	# scale down
	scale_egg(selected_egg_inx, SMALL_EGG_SCALE, .2)
	
	# move animation
	var s: Control = placed_egg_sprites[selected_egg_inx]
	move_buffers = [FloatBuffer.new(s.position.x), FloatBuffer.new(s.position.y)]
	tween(move_buffers[0], "value", goal.x, 0., 1.)  # x pos to center
	tween(move_buffers[1], "value", goal.y - 50, 0., .6)  # up
	tween(move_buffers[1], "value", goal.y, 0.2, .4, Tween.EASE_IN)  # down
	tween(s, "scale", scale_goal, .12, .5, Tween.EASE_IN).connect("finished", end_movement.bind(s))  # scale up & finish movement event

## bring back egg selection
func back_btn_input(event: InputEvent):
	if can_interact and selected_egg_inx != null and event.is_pressed():
		set_can_interact(false)
		fade(back_btn, false)
		fade(bar_container, false)
		tween_sprite_to_goal(original_egg_positions[selected_egg_inx], BASE_EGG_SCALE, true)
		
		# reset texts, shader & rotation
		selection_title.text = select_title_text % [STRING_SELECT_YOUR_EGG]
		tween(shader_area.material, "shader_parameter/color", Vector4(0, 0, 0, 1), 0., 1., Tween.EASE_IN_OUT)
		placed_egg_sprites[selected_egg_inx].rotation = 0
		
		# fade back in other eggs
		for i: int in placed_egg_sprites.size():
			if i != selected_egg_inx:
				var sprite_c: Control = placed_egg_sprites[i]
				tween(sprite_c, "modulate", Color(1, 1, 1, 1), 0., .4)  # fade in
				tween(sprite_c, "position", original_egg_positions[i], 0., .3)  # move up

## update bar, egg scale & egg rotation
func update_selected_egg(delta):
	var percent: float = bar.value / bar.max_value
	var sprite_c: Control = placed_egg_sprites[selected_egg_inx]
	
	# bar
	bar.value -= BAR_DRAIN_AMOUNT * delta
	bar["theme_override_styles/fill"].bg_color = bar_progress_color.sample(percent)
	
	# scale
	sprite_c.scale = BASE_SELECTED_EGG_SCALE + (MAX_SELECTED_EGG_SCALE - BASE_SELECTED_EGG_SCALE) * percent
	sprite_c.scale += scale_addition  # for mouse hovering
	
	# rotation
	if can_interact:
		var freq = Time.get_unix_time_from_system() * 15 + (10 * percent)
		var amp = .08 + (.08 * percent)  # additions are for randomness
		sprite_c.rotation = (sin(freq) * amp) * rotation_buffer.value

func update_hatching_egg():
	var sprite_c: Control = placed_egg_sprites[selected_egg_inx]
	var freq = Time.get_unix_time_from_system() * 20
	var amp = .15 + (.04 * hatch_progress)
	sprite_c.rotation = (sin(freq) * amp) * rotation_buffer.value

func _process(delta):
	# hatching
	if hatching:
		update_hatching_egg()
	
	# progress bar
	if selected_egg_inx != null and !hatching:
		update_selected_egg(delta)
	
	# bob eggs slowly
	if selected_egg_inx == null:  # do all
		for i: int in placed_egg_sprites.size():
			var s = sin(Time.get_unix_time_from_system() - (1. * i)) * 6
			placed_egg_sprites[i].position.y = original_egg_positions[i].y + s
	elif can_interact and !hatching:  # do only selected
		var s = sin(Time.get_unix_time_from_system()) * 6
		placed_egg_sprites[selected_egg_inx].position.y = original_egg_positions[selected_egg_inx].y + s
	
	# move selected egg animation
	if move_buffers.size() > 0 and selected_egg_inx != null:
		var new_p = Vector2(move_buffers[0].value, move_buffers[1].value)
		placed_egg_sprites[selected_egg_inx].position = new_p

class FloatBuffer:
	var value: float = 0.
	func _init(v):
		value = v
