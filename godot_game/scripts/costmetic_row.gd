extends GridContainer

var unlockables = load("res://resources/unlockables.tres")
@export var category: CosmeticItem.Cosmetic_Category
## Class that describes the button object for each cosmetic item.
class UnlockableIcon extends Button:
	var cosmetic_name
	
	func _init(unlockable: CosmeticItem, is_unlocked: bool):
		# Universal Styling and sizeing
		custom_minimum_size = Vector2(64,64)
		size.x = 64
		size.y = 64
		add_theme_constant_override("icon_max_width", 50)
		theme = load("res://themes/menu_btn.tres")
		expand_icon = false
		# Individual properites
		tooltip_text = unlockable.desc
		icon = unlockable.thumbnail
		cosmetic_name = unlockable.name
		disabled = !unlockable.unlocked 
		
	## Action when button is pressed.
	func _pressed():
		print(self.cosmetic_name)


func _ready():
	# Dynamically build menu
	for i in range(5):
		for item in unlockables.unlockables:
			if item.category == category:
				var unlock_item = UnlockableIcon.new(item, false)
				add_child(unlock_item)


## Update menu when an item is unlocked.
func update_menu():
	var unlocked_items = DataGlobals.metadata_last_loaded[DataGlobals.UNLOCKED_ITEMS]
	
	for item: CosmeticItem in unlockables.unlockables:
		var uid = ResourceLoader.get_resource_uid(item.resource_path)
		var is_unlocked = item.unlocked or uid in unlocked_items
		
		var item_btn = UnlockableIcon.new(item, is_unlocked)
		add_child(item_btn)
