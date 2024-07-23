extends Sprite2D

class_name TetBody

signal no_collisions

const TEXTURE_PATH = 'res://totris/tetrominos/'
const TOP = 0
const BOTTOM = 1
const LEFT = 2
const RIGHT = 3

const SWITCH = -1  # special case for rotation
const ROTATION = 10
const SIZE = 11
const COLOUR = 12
const FRAMES = 13
const PARTICLE = 14

## tet frames define square allowance on sides for each frame of each tetromino (needed since every texture is a square)
const TET_VALUES = {
	"l_a": {SIZE: Vector2(90, 90), FRAMES: {0: "0100", 1: "0010", 2: "1000", 3: "0001"}, ROTATION: 90, COLOUR: Color(30, 90, 255)},
	"l_b": {SIZE: Vector2(90, 90), FRAMES: {0: "1000", 1: "0001", 2: "0100", 3: "0010"}, ROTATION: 90, COLOUR: Color(255, 200, 120)},
	"long": {SIZE: Vector2(120, 120), FRAMES: {0: "1200", 1: "0021"}, ROTATION: SWITCH, COLOUR: Color(150, 255, 255)},
	"skew_a": {SIZE: Vector2(90, 90), FRAMES: {0: "1000", 1: "0010"}, ROTATION: -90, COLOUR: Color(150, 255, 140)},
	"skew_b": {SIZE: Vector2(90, 90), FRAMES: {0: "1000", 1: "0010"}, ROTATION: -90, COLOUR: Color(255, 110, 90)},
	"square": {SIZE: Vector2(60, 60), FRAMES: {0: "0000"}, ROTATION: 0, COLOUR: Color(253, 255, 127)},
	"t": {SIZE: Vector2(90, 90), FRAMES: {0: "1000", 1: "0001", 2: "0100", 3: "0010"}, ROTATION: 90, COLOUR: Color(190, 115, 255)}
}

@onready var VARIANT_VALUES = {
	"bonus_points": {COLOUR: Color(100, 255, 140)}
}

var ghost: Sprite2D;
var base_pos: Vector2
var relative_pos: Vector2 = Vector2(0, 0)
var collision_area: Area2D
var og_coll_positions = {}  # key: node name, value: pos
var current_rotation = 0
var current_variant = null
var current_animation: String
var current_frame: int

# tweens
var should_tween = true
const TWEEN_OFFSET = 1
const TWEEN_ROTATION = 2
const TWEEN_MODULATE = 3
var tweeners = {TWEEN_OFFSET: null, TWEEN_ROTATION: null, TWEEN_MODULATE: null}
var t_offset: Vector2 = Vector2(0, 0)
var t_rotation: float = 0
var t_modulate: Color = Color(1, 1, 1)


func get_normal(direction: int) -> int:
	return int(TET_VALUES[current_animation][FRAMES][current_frame][direction])

func get_rotation_addition() -> int:
	return int(TET_VALUES[current_animation][ROTATION])

func get_colour() -> Color:
	if current_variant:
		return Color(VARIANT_VALUES[current_variant][COLOUR])
	return Color(TET_VALUES[current_animation][COLOUR])

func get_frame_count() -> int:
	return int(len(TET_VALUES[current_animation][FRAMES].keys()))

func get_size() -> Vector2:
	return TET_VALUES[current_animation][SIZE]

## returns duplicated, emmiting particle
func get_variant_particle():
	var p: GPUParticles2D = VARIANT_VALUES[current_variant][PARTICLE].duplicate()
	p.emitting = true
	p.visible = true
	return p

## clips size based on tet normals
func get_clipped_size() -> Vector2:
	return get_size() - Vector2(30, 30) * Vector2(
		get_normal(LEFT) + get_normal(RIGHT),
		get_normal(TOP) + get_normal(BOTTOM)
	)

## clip position to centre of tet normals (centre of clipped size)
func get_clipped_pos(relative=true) -> Vector2:
	return (relative_pos if relative else position) + (Vector2(15, 15) * Vector2(
		get_normal(LEFT) - get_normal(RIGHT),
		get_normal(TOP) - get_normal(BOTTOM)
	))

## converts all zeros to positive numbers
func negative_zero_correction(vec: Vector2) -> Vector2:
	return Vector2(
		vec.x if int(vec.x) != 0 else 0.0,
		vec.y if int(vec.y) != 0 else 0.0
	)

## rotate a position by current_rotation around 0, 0
func rotate_point(radians, point: Vector2, centre: Vector2 = Vector2(0, 0)) -> Vector2:
	var out = Vector2(point)
	out.x = centre.x + cos(radians) * (point.x - centre.x) - sin(radians) * (point.y - centre.y)
	out.y = centre.y + sin(radians) * (point.x - centre.x) + cos(radians) * (point.y - centre.y)
	return negative_zero_correction(out)

## returns with a list of (rotated) collision points for this tet
func get_raw_collision_points():
	var points = []
	for point: CollisionShape2D in collision_area.get_children():
		if !point.disabled:
			points.append(Vector2(base_pos + relative_pos + point.position))
	
	# has no more collision points, delete
	if len(points) == 0:
		no_collisions.emit()
	return points

## returns the collision node of the body at the given screen position
## only ever called on already placed pieces so rotation wont change
func get_coll_node_from_raw_position(raw_pos: Vector2):
	for node: CollisionShape2D in collision_area.get_children():
		if !node.disabled and raw_pos - (base_pos + relative_pos) == node.position:
			return node
	print("FAILED to find child collision point at position %s, %s" % [raw_pos.x, raw_pos.y])

func setup_body(anim, ghost_node: Sprite2D = null):
	assert(anim in TET_VALUES.keys())
	current_animation = anim
	collision_area = find_child(current_animation)
	collision_area.visible = true
	
	# ghost
	if ghost_node:
		ghost = ghost_node
		ghost.visible = true
	
	# sprites
	var base_sprite: Sprite2D = Sprite2D.new()
	base_sprite.texture = load(TEXTURE_PATH + current_animation + ".png")
	base_sprite.z_index = -1  # below so i can still see collisions
	var coll_sprite = base_sprite.duplicate()
	
	# setuo variant
	var variant_handler = null
	if current_variant == "bonus_points":
		variant_handler = VariantBonusPoints.new(self)
	
	for coll: CollisionShape2D in collision_area.get_children():
		coll.visible = !coll.disabled
		og_coll_positions[coll.name] = coll.position
		var s = coll_sprite.duplicate()
		coll.add_child(s)
		if variant_handler:
			variant_handler.add(s)
		
		if ghost_node:
			var ghost_sprite = base_sprite.duplicate()
			ghost_sprite.position = coll.position
			ghost_sprite.visible = coll.visible
			ghost.add_child(ghost_sprite)

func set_x(x):
	set_pos(Vector2(x, relative_pos.y))

func set_y(y):
	set_pos(Vector2(relative_pos.x, y))

func add_x(x):
	set_pos(Vector2(relative_pos.x + x, relative_pos.y))

func add_y(y):
	set_pos(Vector2(relative_pos.x, relative_pos.y + y))

func set_pos(vec: Vector2):
	relative_pos = vec
	correct_pos()

func correct_pos():
	position = base_pos + relative_pos

func set_x_offset(val):
	t_offset.x = val

func set_angle(rad):
	t_rotation = rad

func set_modulate_col(col: Color):
	t_modulate = col

## NOTE: call AFTER updating collision points
func update_ghost_rotation():
	for i in ghost.get_child_count():
		ghost.get_child(i).position = collision_area.get_child(i).position

## rotates (or switches) the collision area based on its rotation addition
func update_collision():
	var addition = get_rotation_addition()
	if addition == SWITCH:  # special case for long
		for c in collision_area.get_children():
			c.disabled = !c.disabled
			c.visible = !c.disabled
		for sp: Sprite2D in ghost.get_children():
			sp.visible = !sp.visible
	else:  # rotate normally
		current_rotation = addition * current_frame
		for node: CollisionShape2D in collision_area.get_children():
			node.position = rotate_point(current_rotation * (PI / 180), og_coll_positions[node.name])

## rotates body clockwise
func advance_frame():
	var frame_count = get_frame_count()
	if frame_count > 0:
		current_frame = (current_frame + 1) % frame_count
		update_collision()
		update_ghost_rotation()

## rotates body counter clockwise
func rewind_frame():
	current_frame -= 1 if current_frame > 0 else -(get_frame_count() - 1)
	update_collision()
	update_ghost_rotation()

## update the things that need tweening
func _process(_delta):
	if should_tween:
		var props_to_update = []
		var t_off = tweeners[TWEEN_OFFSET]
		var t_rot = tweeners[TWEEN_ROTATION]
		var t_mod = tweeners[TWEEN_MODULATE]
		if t_off and t_off.is_running():
			props_to_update.append("offset")
		if t_rot and t_rot.is_running():
			props_to_update.append("rotation")
		if t_mod and t_mod.is_running():
			props_to_update.append("modulate")
		
		for prop in props_to_update:
			for coll: CollisionShape2D in collision_area.get_children():
				var sprite: Sprite2D = coll.get_child(0)
				if prop == "rotation":  # extra case for rotation so each sprite rotates around centre of the body (rather than just rotating around itself)
					sprite.offset = rotate_point(t_rotation, coll.position) - coll.position
				sprite[prop] = self["t_" + prop]

## creates a tween & performs it on the nessecary values
func perform_tween(tween_type: int, goal, time: float):
	if should_tween:
		if tweeners[tween_type] != null:
			tweeners[tween_type].kill()
		tweeners[tween_type] = get_tree().create_tween()
		var property = "t_offset" if tween_type == TWEEN_OFFSET else ("t_modulate" if tween_type == TWEEN_MODULATE else "t_rotation")
		tweeners[tween_type].tween_property(self, property, goal, time)

func place_body():
	ghost.visible = false
	should_tween = false
	for coll: CollisionShape2D in collision_area.get_children():
		var sp: Sprite2D = coll.get_child(0)
		sp.offset = Vector2(0, 0)
		sp.rotation = 0
		sp.modulate = Color(1, 1, 1)

## for the class's shine timer to connect to
func do_bonus_points_shine(v_b_p: VariantBonusPoints):
	v_b_p.do_shine()

class VariantBonusPoints:
	var body: TetBody
	var all_sprites = []
	var shader: ShaderMaterial = ShaderMaterial.new()
	var timer: Timer = Timer.new()
	
	func _init(parent: TetBody):
		body = parent
		shader.shader = load("res://shaders/shine.gdshader")
		shader.set_shader_parameter("shine_color", Color(1, 1, 1, 0.5))
		shader.set_shader_parameter("shine_size", 0.15)
		
		timer.wait_time = 2
		timer.autostart = true
		body.add_child(timer)
		timer.timeout.connect(body.do_bonus_points_shine.bind(self))
	
	func add(sprite: Sprite2D):
		sprite.material = shader.duplicate()
		all_sprites.append(sprite)
	
	func do_shine():
		for sp in all_sprites:
			if is_instance_valid(sp):  # ignore previously freed
				sp.material.set_shader_parameter("shine_progress", 0.0)
				var tween = body.get_tree().create_tween()
				tween.tween_property(sp.material, "shader_parameter/shine_progress", 1, 0.5)
			else:
				all_sprites.erase(sp)
		
		# no need to continue
		if len(all_sprites) == 0:
			timer.stop()
			timer.queue_free()
