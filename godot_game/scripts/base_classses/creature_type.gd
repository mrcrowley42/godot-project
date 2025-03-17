class_name CreatureType extends Resource
## A custom resource to store the information about an individual creature

@export var name: String = "Defaut name"
@export var desc: String = "Default description"
## for both growing up and laying egg
@export var xp_threshold: int = 1000
@export var child: CreatureTypePart
@export var adult: CreatureTypePart
