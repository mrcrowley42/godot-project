extends Node

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

const NOFITICATION_GROW_TO_ADULT_SCENE = 502
const NOTIFICATION_CREATURE_IS_LOADED = 503
const NOTIFICATION_CREATURE_ACCESSORIES_ARE_LOADED = 504
const NOTIFICATION_AMBIENT_SOUNDS_REMOVED = 505


signal item_unlocked(details)

## save incase we need to kill it for another transition
var transition_tween: Tween = null

## for use when passing data between scenes
# please use .erase() after extracting items to keep everything clean
var general_dict: Dictionary = {}


# ------------------------------
#    general helper functions
# ------------------------------


func change_to_scene(scene_path: String):
	await get_tree().process_frame  # important
	get_tree().change_scene_to_file(scene_path)

func send_notification(noti: int):
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
	var unlocked_facts = DataGlobals.load_metadata()['unlocked_facts']
	if fact_uid in unlocked_facts:
		return
	# If item isn't unlocked, add it to unlocked list.
	DataGlobals.metadata_to_add[DataGlobals.UNLOCKED_FACTS] = [fact_uid]
	DataGlobals.save_only_metadata()
	# Display notification
	var message = "%s Unlocked!" %[fact.title]
	item_unlocked.emit(message)


## Unlocks the passed [param cosmetic] resource
func unlock_cosmetic(cosmetic: CosmeticItem) -> void:
	# Ignore already unlocked
	if cosmetic.unlocked:
		return
	var cosmetic_uid = Helpers.uid_str(cosmetic)
	var unlocked_cosmetics = DataGlobals.load_metadata()['unlocked_cosmetics']
	if cosmetic_uid in unlocked_cosmetics:
		return
	# If item isn't unlocked, add it to unlocked list.
	DataGlobals.metadata_to_add[DataGlobals.UNLOCKED_COSMETICS] = [cosmetic_uid]
	DataGlobals.save_only_metadata()
	# Display notification
	var message = "%s Unlocked!" %[cosmetic.name]
	item_unlocked.emit(message)

## Unlocks the passed [param cosmetic] resource
func unlock_theme(theme: UiTheme) -> void:
	# Ignore already unlocked
	if theme.unlocked:
		return
	var theme_uid = Helpers.uid_str(theme)
	var unlocked_themes = DataGlobals.load_metadata()['unlocked_themes']
	if theme_uid in unlocked_themes:
		return
	# If item isn't unlocked, add it to unlocked list.
	DataGlobals.metadata_to_add[DataGlobals.UNLOCKED_THEMES] = [theme_uid]
	DataGlobals.save_only_metadata()
	# Display notification
	var message = "%s Unlocked!" %[theme.theme_name]
	item_unlocked.emit(message)

# TODO: really want to refactor these functions into one now...

## generic tween function
func tween(obj, prop, val, delay=0., time=2., _ease=Tween.EASE_OUT):
	var t = create_tween()
	t.tween_property(obj, prop, val, time)\
			.set_trans(Tween.TRANS_EXPO)\
			.set_ease(_ease)\
			.set_delay(delay)
	return t
