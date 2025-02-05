extends Node

## update this on update (please)
const VERSION = "1.0.0"
const BUILD = "BETA"

# SAVE CONSTANTS
const SAVE_DATA_GROUP = "save_data"
const SAVE_DATA_FILE = "res://save_data.save"

const SAVE_SETTINGS_GROUP = "settings_data"
const SAVE_SETTINGS_FILE = "res://settings.cfg"

# SETTINGS SECTIONS
const DEFAULT_SECTION = "general"
const AUDIO_SECTION = "audio"
const UI_SECTION = "user interface"
const MAX_AMBIENT_SOUNDS = 6

# CUSTOM NOTIFICATIONS
const NOTIFICATION_MINIGAME_CLOSED = 600
const NOTIFICATION_TOTRIS_CLOSE = 601
const NOTIFICATION_MEMORY_MATCH_CLOSE = 602
const NOTIFICATION_SPROCK_CLOSED = 603

const NOFITICATION_GROW_TO_ADULT_SCENE = 502
const NOTIFICATION_CREATURE_IS_LOADED = 503
const NOTIFICATION_CREATURE_ACCESSORIES_ARE_LOADED = 504
const NOTIFICATION_AMBIENT_SOUNDS_REMOVED = 505
const NOTIFICATION_ALL_DATA_IS_LOADED = 506
const NOTIFICATION_QUIT_TO_MAIN_MENU = 507

const NOTI_LOOKUP = {
	NOTIFICATION_MINIGAME_CLOSED: "NOTIFICATION_MINIGAME_CLOSED",
	NOTIFICATION_TOTRIS_CLOSE: "NOTIFICATION_TOTRIS_CLOSE",
	NOTIFICATION_MEMORY_MATCH_CLOSE: "NOTIFICATION_MEMORY_MATCH_CLOSE",
	NOTIFICATION_SPROCK_CLOSED: "NOTIFICATION_SPROCK_CLOSED",
	
	NOFITICATION_GROW_TO_ADULT_SCENE: "NOFITICATION_GROW_TO_ADULT_SCENE",
	NOTIFICATION_CREATURE_IS_LOADED: "NOTIFICATION_CREATURE_IS_LOADED",
	NOTIFICATION_CREATURE_ACCESSORIES_ARE_LOADED: "NOTIFICATION_CREATURE_ACCESSORIES_ARE_LOADED",
	NOTIFICATION_AMBIENT_SOUNDS_REMOVED: "NOTIFICATION_AMBIENT_SOUNDS_REMOVED",
	NOTIFICATION_ALL_DATA_IS_LOADED: "NOTIFICATION_ALL_DATA_IS_LOADED",
	NOTIFICATION_QUIT_TO_MAIN_MENU: "NOTIFICATION_QUIT_TO_MAIN_MENU"
}


signal item_unlocked
signal cosmetic_unlocked(uid)
signal theme_unlocked(uid)
signal fact_unlocked(uid)

## save incase we need to kill it for another transition
var transition_tween: Tween = null

## for use when passing data between scenes
# please use .erase() after extracting items to keep everything clean
var general_dict: Dictionary = {}

var fact_icons: FactIconList = preload("res://resources/fact_icons.tres")


# ------------------------------
#    general helper functions
# ------------------------------


func change_to_scene(scene_path: String):
	print("changing to scene '%s'" % scene_path)
	await get_tree().process_frame  # important
	get_tree().change_scene_to_file(scene_path)

func send_notification(noti: int):
	print("pushing notification '%s', '%s'" % [noti, NOTI_LOOKUP[noti] if NOTI_LOOKUP.has(noti) else "UNKNOWN"])
	get_tree().root.propagate_notification(noti)

func perform_opening_transition(trans_img: Sprite2D, mid_pos: Vector2, end_func=null):
	if transition_tween != null and transition_tween.is_running():
		transition_tween.stop()
	
	trans_img.rotation = 0
	trans_img.position = mid_pos
	transition_tween = tween(trans_img, "position", trans_img.position + Vector2(0, 1000), 0.3, 1.5)
	
	await get_tree().create_timer(.5).timeout
	if end_func != null:
		end_func.call()

func perform_closing_transition(trans_img: Sprite2D, mid_pos: Vector2, end_func=null):
	if transition_tween != null and transition_tween.is_running():
		transition_tween.stop()
	
	trans_img.rotation = PI
	trans_img.position.y = -1000
	transition_tween = tween(trans_img, "position", mid_pos, .0, 1)
	
	await get_tree().create_timer(.5).timeout
	if end_func != null:
		end_func.call()


## Unlocks the passed [param fact] resource
func unlock_fact(fact: Fact) -> void:
	# Ignore already unlocked facts
	if fact.unlocked:
		return
	var fact_uid = Helpers.uid_str(fact)
	var unlocked_facts = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_FACTS)
	if fact_uid in unlocked_facts:
		return
	
	DataGlobals.append_to_metadata_value(true, DataGlobals.UNLOCKED_FACTS, fact_uid)
	
	print("fact unlocked '%s', uid: '%s'" % [fact.title, fact_uid])
	item_unlocked.emit("Fact Unlocked!", get_fact_category_icon(fact.category))
	fact_unlocked.emit(fact_uid)


## Unlocks the passed [param cosmetic] resource
func unlock_cosmetic(cosmetic: CosmeticItem) -> void:
	# Ignore already unlocked
	if cosmetic.unlocked:
		return
	var cosmetic_uid = Helpers.uid_str(cosmetic)
	var unlocked_cosmetics = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_COSMETICS)
	if cosmetic_uid in unlocked_cosmetics:
		return
	
	DataGlobals.append_to_metadata_value(true, DataGlobals.UNLOCKED_COSMETICS, cosmetic_uid)
	
	print("cosmetic unlocked '%s', uid: '%s'" % [cosmetic.name, cosmetic_uid])
	item_unlocked.emit("Cosmetic Unlocked!", cosmetic.thumbnail)
	cosmetic_unlocked.emit(cosmetic_uid)

## Unlocks the passed [param cosmetic] resource
func unlock_theme(theme: UiTheme) -> void:
	# Ignore already unlocked
	if theme.unlocked:
		return
	var theme_uid = Helpers.uid_str(theme)
	var unlocked_themes = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_THEMES)
	if theme_uid in unlocked_themes:
		return
	
	DataGlobals.append_to_metadata_value(true, DataGlobals.UNLOCKED_THEMES, theme_uid)
	
	print("theme unlocked '%s', uid: '%s'" % [theme.theme_name, theme_uid])
	
	# generate the image!
	var img: Image = Image.create(32, 32, false, Image.Format.FORMAT_RGBA8)
	for y in range(32):
		for x in range(32):
			var col = Color(1, 1, 1, 0)
			var dist: float = Vector2(x, y).distance_to(Vector2(16, 16))
			if dist < 12:
				col = theme.primary if dist > 9 else theme.bg
			img.set_pixel(x, y, col)
	item_unlocked.emit("Theme Unlocked!", ImageTexture.create_from_image(img))
	theme_unlocked.emit(theme_uid)

# TODO: really want to refactor these functions into one now...

## generic tween function
func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_OUT):
	var t = create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t

func has_function(node: Node, method: String) -> bool:
	if not node.has_method(method):
		printerr("Node '%s' at path '%s' does not have '%s()' function" % [node, node.get_path(), method])
		return false
	return true

## return tuple 0: unlocked count, 1: total count
func get_fact_category_progress(category) -> Array[int]:
	var unlocked_facts = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_FACTS)
	var fact_list = load("res://resources/fact_list.tres").facts
	var facts = fact_list.filter(func(x): return x.category == category)
	var unlocked = facts.filter(func(x): return Helpers.uid_str(x) in unlocked_facts or x.unlocked)
	return [len(unlocked), len(facts)]

func get_fact_category_icon(category: Fact.FactCategory) -> Texture2D:
	for fact_icon: FactIcon in fact_icons.facts:
		if fact_icon.fact_category == category:
			return fact_icon.icon
	return null

func spawn_exclamation_point(parent) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.position = Vector2(5, 5)
	sprite.modulate = Color(1, 1, 0, 1)
	sprite.scale = Vector2(.8, .8)
	sprite.texture = load("res://icons/exclamation-lg.svg")
	parent.add_child(sprite)
	return sprite

## fire confetti, automatically removes iteslf of finish
func fire_confetti(parent, pos: Vector2 = Vector2(270, 560)):
	var remove = func(p_node):
		p_node.queue_free()
	
	var c_1 = ConfettiParticle.new(pos + Vector2(-180, 0), .1)
	var c_2 = ConfettiParticle.new(pos + Vector2(180, 0), -.1)
	c_1.emitting = true
	c_2.emitting = true
	c_1.connect("finished", remove.bind(c_1))
	c_2.connect("finished", remove.bind(c_2))
	parent.add_child(c_1)
	parent.add_child(c_2)


class ConfettiParticle extends CPUParticles2D:
	func _init(pos: Vector2, direc) -> void:
		amount = 15; lifetime = 2; one_shot = true
		explosiveness = 1; randomness = 1;
		direction = Vector2(direc, -1); spread = 6;
		initial_velocity_min = 500; initial_velocity_max = 900;
		angular_velocity_min = -100; angular_velocity_max = 100;
		scale_amount_min = 10; scale_amount_max = 15;
		
		var gradient = Gradient.new()
		gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT;
		gradient.offsets = PackedFloat32Array([0, .125, .3, .45, .65, .820, 1]);
		gradient.colors = PackedColorArray([Color.RED, Color.ORANGE, Color.YELLOW, Color.MAGENTA, Color.GREEN_YELLOW, Color.PURPLE, Color.WHITE])
		color_initial_ramp = gradient
		
		hue_variation_min = 1; hue_variation_max = 1;
		position = pos
