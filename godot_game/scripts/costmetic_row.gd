extends GridContainer

const BTN_SIZE: Vector2 = Vector2(64, 64)

var unlockables = load("res://resources/unlockables.tres")
@export var category: CosmeticItem.Cosmetic_Category

## Class that describes the button object for each cosmetic item.
class UnlockableIcon extends Button:
	var cosmetic_name
	
	func _init(unlockable: CosmeticItem, is_unlocked: bool):
		# Universal Styling and sizeing
		custom_minimum_size = BTN_SIZE
		size = BTN_SIZE
		theme = load("res://themes/menu_btn.tres")
		expand_icon = false
		add_theme_constant_override("icon_max_width", 50)
		
		# Individual properites
		tooltip_text = unlockable.desc
		icon = unlockable.thumbnail
		cosmetic_name = unlockable.name
		if not is_unlocked or !unlockable.unlocked:
			disabled = true
		
	## Action when button is pressed.
	func _pressed():
		print(self.cosmetic_name)


func _ready():
	var unlocked_items = DataGlobals.metadata_last_loaded[DataGlobals.UNLOCKED_ITEMS]
	
	for item: CosmeticItem in unlockables.unlockables:
		var uid = ResourceLoader.get_resource_uid(item.resource_path)
		var is_unlocked = item.unlocked or uid in unlocked_items
		
		if item.category == category:
			var item_btn = UnlockableIcon.new(item, is_unlocked)
			add_child(item_btn)
