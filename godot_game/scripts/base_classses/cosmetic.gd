extends Resource
class_name CosmeticItem
## A custom resource to store the information about an unlockable cosmetic.
@export var name: String
@export_multiline var desc: String
@export var unlocked: bool = false