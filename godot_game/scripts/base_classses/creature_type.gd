class_name CreatureType extends Resource
## A custom resource to store the information about an individual creature

@export var name: String
@export var desc: String
@export var xp_required_for_adult: int
@export var baby: CreatureTypePart
@export var adult: CreatureTypePart
