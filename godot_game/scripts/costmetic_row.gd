extends GridContainer

@warning_ignore("unused_signal")  # shut up
signal cosmetic_btn_pressed

const BTN_SIZE: Vector2 = Vector2(64, 64)

var unlockables = load("res://resources/unlockables.tres")
@export var creature: Creature
var data_is_loaded = false

## Class that describes the button object for each cosmetic item.
class UnlockableIcon extends CustomTooltipButton:
	var cosmetic

	func _init(unlockable: CosmeticItem):
		theme = load("res://themes/cosmetic_btn_theme.tres")
		custom_minimum_size = BTN_SIZE
		toggle_mode = true
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		size = BTN_SIZE
		expand_icon = false
		add_theme_constant_override("icon_max_width", 50)
		cosmetic = unlockable
		update_locked()

	## Action when button is pressed.
	func _pressed():
		var parent = find_parent("CosmeticItems")
		var creature: Creature = parent.creature
		var manager: AccessoryManager = creature.find_child("AccessoryManager")
		manager.toggle_cosmetic(self.cosmetic)
		parent.cosmetic_btn_pressed.emit()

	func update_locked():
		var unlocked_items = DataGlobals.get_global_metadata_value(DataGlobals.UNLOCKED_COSMETICS)
		var uid = Helpers.uid_str(self.cosmetic)
		self.disabled = false if self.cosmetic.unlocked else not uid in unlocked_items
		self.tooltip_string = ("Locked: " + cosmetic.hint) if disabled else cosmetic.desc
		self.direction = DIRECTION.DOWN
		self.margin = 14
		self.text = "?" if self.disabled else ""
		icon = null if self.disabled else cosmetic.thumbnail


func _notification(what: int) -> void:
	if what == Globals.NOTIFICATION_ALL_DATA_IS_LOADED:
		data_is_loaded = true
		for item: CosmeticItem in unlockables.unlockables:
			var item_btn = UnlockableIcon.new(item)
			add_child.call_deferred(item_btn)

func update_buttons():
	propagate_call("update_locked")


func update_toggle():
	var loaded = creature.accessory_manager.current_cosmetics
	for child in get_children():
		if child.cosmetic.name in loaded:
			child.set_pressed_no_signal(true)

func _on_cosmetics_menu_visibility_changed():
	if %CosmeticsMenu.visible and data_is_loaded:
		update_toggle()
		$"../..".scroll_vertical = 0
