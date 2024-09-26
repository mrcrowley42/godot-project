class_name CreatureTypePart extends Resource
## A custom resource to store the information about an individual creature

@export var max_hp: int
@export var max_water: int
@export var max_food: int
@export var max_fun: int
@export var sprite_frames: SpriteFrames
@export var notification_position: Vector2
@export var cosmetic_positions: Array[CosmeticPosition]
@export_group("Preferences")
@export var likes: Array[Creature.FoodItem]
@export var dislikes: Array[Creature.FoodItem]
