class_name Fact extends Resource

## A custom resource to store the information of a single fact.

enum FactCategory {FUN, NEURO, ETC}

@export var title: String
@export var category: FactCategory
@export var source: String
@export_multiline var fact: String
@export var unlocked: bool
@export var hint: String = ""
