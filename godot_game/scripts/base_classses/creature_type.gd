class_name CreatureType extends Resource
## A custom resource to store the information about an individual creature

@export var creature_name: String
@export var max_hp: int
@export var max_water: int
@export var max_food: int
@export var max_fun: int
@export var likes: Array[Creature.FoodItem]
@export var dislikes: Array[Creature.FoodItem]
@export var sprite_frames: SpriteFrames
