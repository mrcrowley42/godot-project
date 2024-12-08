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
@export var food_likes: Array[FoodItem.FoodType]
@export var food_dislikes: Array[FoodItem.FoodType]
@export var drink_likes: Array[DrinkItem.DrinkType]
@export var drink_dislikes: Array[DrinkItem.DrinkType]
