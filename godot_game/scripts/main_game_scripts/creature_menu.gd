extends GridContainer

@onready var creature_list = load("res://resources/creature_list.tres")
@onready var creature_info_scene = load("res://scenes/UiScenes/creature_info.tscn")
const BTN_SIZE = Vector2(340,64)

### Class that describes the button object for each creature.
class CreatureIcon extends CustomTooltipButton:
	var creature_data
	func _init(creature: CreatureType):
		size = BTN_SIZE
		creature_data = creature
		theme = load("res://themes/cosmetic_btn_theme.tres")
		icon = creature.baby.sprite_frames.get_frame_texture("idle",0)
		custom_minimum_size = BTN_SIZE
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		expand_icon = false
		add_theme_constant_override("icon_max_width", 100)
		update_locked()
	
	func has_encountered(creature_type) -> bool:
		var uid = Helpers.uid_str(creature_type)
		return uid in DataGlobals.get_metadata_value(DataGlobals.DISCOVERED_CREATURES)
	
	### Action when button is pressed.
	func _pressed():
		var parent = find_parent("CreaturesMenu")
		var scene = parent.find_child("Creatures").creature_info_scene.instantiate()
		scene.creature = self.creature_data
		scene.setup()
		parent.add_child(scene)

	func update_locked():
		self.disabled = !has_encountered(self.creature_data)
		text = self.creature_data.name if not self.disabled else "???"
		#icon = null if self.disabled else cosmetic.thumbnail

func _ready():
	for i in range(3):
		for creature in creature_list.items:
			var btn = CreatureIcon.new(creature)
			add_child(btn)

#func _on_visibility_changed():
	#$"../..".scroll_vertical = 0
