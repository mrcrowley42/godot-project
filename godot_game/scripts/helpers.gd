class_name Helpers extends Node
## A Class used to store commonly reused functions across the project.

## Returns the new index of an Array that should wrap around, when shifted by [param offset] places.
static func wrap_index(list: Array, current_index: int, offset: int) -> int:
	var new_index = (current_index + offset) % list.size()
	if new_index < 0:
		new_index = list.size() + new_index
	return new_index
