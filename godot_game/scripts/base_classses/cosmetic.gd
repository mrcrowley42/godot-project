extends Resource
class_name CosmeticItem

enum Cosmetic_Category {HAT, GLASSES}

## A custom resource to store the information about an unlockable cosmetic.
@export var name: String
@export_multiline var desc: String
@export var unlocked: bool = false
@export var thumbnail: Texture2D
@export var category: Cosmetic_Category
@export var sprite: SpriteFrames
