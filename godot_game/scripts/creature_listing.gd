extends Button

@export var name_label: Label
var creature_data: CreatureType

func _ready() -> void:
	update_locked()

func has_encountered(creature_type) -> bool:
	var uid = Helpers.uid_str(creature_type)
	return uid in DataGlobals.get_global_metadata_value(DataGlobals.DISCOVERED_CREATURES)


func update_locked():
	self.disabled = !has_encountered(self.creature_data)
	name_label.text = self.creature_data.name if not self.disabled else "???"
	#icon = null if self.disabled else cosmetic.thumbnail

func _on_button_down() -> void:
	var parent = find_parent("CreaturesMenu")
	var scene = parent.find_child("Creatures").creature_info_scene.instantiate()
	scene.creature = self.creature_data
	scene.setup()
	parent.add_child(scene)
