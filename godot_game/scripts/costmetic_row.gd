extends GridContainer

const BTN_SIZE: Vector2 = Vector2(64, 64)

var unlockables = load("res://resources/unlockables.tres")

@export var creature: Creature

## Class that describes the button object for each cosmetic item.
class UnlockableIcon extends Button:
	var cosmetic_name
	var cosmetic_category
	var cosmetic

	func _init(unlockable: CosmeticItem, is_unlocked: bool):
		# Universal Styling and sizeing
		custom_minimum_size = BTN_SIZE
		size = BTN_SIZE
		#theme = load("res://themes/menu_btn.tres")
		expand_icon = false
		add_theme_constant_override("icon_max_width", 50)

		# Individual properites
		cosmetic = unlockable
		tooltip_text = unlockable.desc
		icon = unlockable.thumbnail
		cosmetic_name = unlockable.name
		cosmetic_category = unlockable.Cosmetic_Category
		if not is_unlocked:
			disabled = true

	## Action when button is pressed.
	func _pressed():
		var cre: Creature = find_parent("CosmeticItems").creature
		var be: AccessoryManager = cre.find_child("AccessoryManager")
		be.toggle_cosmetic(self.cosmetic)


	func update_locked():
		var unlocked_items = DataGlobals.load_metadata()['unlocked_cosmetics']
		var uid = str(ResourceLoader.get_resource_uid(self.cosmetic.resource_path))
		self.disabled = false if self.cosmetic.unlocked else not uid in unlocked_items


func _ready():
	var unlocked_items = DataGlobals.load_metadata()['unlocked_cosmetics']
	#var unlocked_items = DataGlobals.metadata_last_loaded[DataGlobals.UNLOCKED_ITEMS]
	for i in range(10): # temp loop to boost numbers to better aid visualisation
		for item: CosmeticItem in unlockables.unlockables:
			var uid = str(ResourceLoader.get_resource_uid(item.resource_path))
			var is_unlocked = true if item.unlocked else uid in unlocked_items
			var item_btn = UnlockableIcon.new(item, is_unlocked)
			add_child(item_btn)


func update_buttons():
	propagate_call("update_locked")


func _on_visibility_changed():
	$"../..".scroll_vertical = 0
