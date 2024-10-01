extends GridContainer

@warning_ignore("unused_signal")  # shut up
signal cosmetic_btn_pressed

const BTN_SIZE: Vector2 = Vector2(64, 64)

var unlockables = load("res://resources/unlockables.tres")

@export var creature: Creature

## Class that describes the button object for each cosmetic item.
class UnlockableIcon extends Button:
	var cosmetic

	func _init(unlockable: CosmeticItem):
		theme = load("res://themes/vcr_font.tres")
		custom_minimum_size = BTN_SIZE
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
		var unlocked_items = DataGlobals.load_metadata()['unlocked_cosmetics']
		var uid = Helpers.uid_str(self.cosmetic)
		self.disabled = false if self.cosmetic.unlocked else not uid in unlocked_items
		self.tooltip_text = cosmetic.hint if disabled else cosmetic.desc
		self.text = "?" if self.disabled else ""
		icon = null if self.disabled else cosmetic.thumbnail


func _ready():
	for item: CosmeticItem in unlockables.unlockables:
		var item_btn = UnlockableIcon.new(item)
		add_child(item_btn)


func update_buttons():
	propagate_call("update_locked")


func _on_visibility_changed():
	$"../..".scroll_vertical = 0
