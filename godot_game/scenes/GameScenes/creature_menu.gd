extends GridContainer

@onready var creature_list = load("res://resources/creature_list.tres")

#@warning_ignore("unused_signal")  # shut up
#signal cosmetic_btn_pressed
#
#const BTN_SIZE: Vector2 = Vector2(64, 64)
#
@onready var creature_info_scene = load("res://scenes/UiScenes/creature_info.tscn")
#var unlockables = load("res://resources/unlockables.tres")
#@export var creature: Creature
#
### Class that describes the button object for each cosmetic item.
class CreatureIcon extends CustomTooltipButton:

	func _init(creature: CreatureType):
		size = Vector2(100,100)
		icon = creature.baby.sprite_frames.get_frame_texture("idle",0)
		#theme = load("res://themes/cosmetic_btn_theme.tres")
		#custom_minimum_size = BTN_SIZE
		#toggle_mode = true
		#icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#size = BTN_SIZE
		#expand_icon = false
		add_theme_constant_override("icon_max_width", 100)
		#cosmetic = unlockable
		#update_locked()
#
	### Action when button is pressed.
	func _pressed():
		var parent = find_parent("CreaturesMenu")
		var scene = parent.find_child("Creatures").creature_info_scene.instantiate()
		parent.add_child(scene)
		#var creature: Creature = parent.creature
		#var manager: AccessoryManager = creature.find_child("AccessoryManager")
		#manager.toggle_cosmetic(self.cosmetic)
		#parent.cosmetic_btn_pressed.emit()
#
	#func update_locked():
		#var unlocked_items = DataGlobals.load_metadata()['unlocked_cosmetics']
		#var uid = Helpers.uid_str(self.cosmetic)
		#self.disabled = false if self.cosmetic.unlocked else not uid in unlocked_items
		#self.tooltip_string = ("Locked: " + cosmetic.hint) if disabled else cosmetic.desc
		#self.direction = DIRECTION.DOWN
		#self.margin = 14
		#self.text = "?" if self.disabled else ""
		#icon = null if self.disabled else cosmetic.thumbnail

func _ready():
	for i in range(3):
		for creature in creature_list.items:
			var btn = CreatureIcon.new(creature)
			add_child(btn)
		
	
	#creature.accessory_manager.cosmetics_loaded.connect(update_toggle)
	#for item: CosmeticItem in unlockables.unlockables:
		#var item_btn = UnlockableIcon.new(item)
		#add_child(item_btn)

#func update_buttons():
	#propagate_call("update_locked")
#
#func update_toggle():
	#var loaded = creature.accessory_manager.current_cosmetics
	#for child in get_children():
		#if child.cosmetic.name in loaded:
			#child.set_pressed_no_signal(true)
#
#func _on_visibility_changed():
	#$"../..".scroll_vertical = 0