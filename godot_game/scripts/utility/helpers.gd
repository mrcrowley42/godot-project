class_name Helpers extends Node
## A Class used to store commonly reused functions across the project.

## Returns the new index of an Array that should wrap around, when shifted by [param offset] places.
static func wrap_index(list: Array, current_index: int, offset: int) -> int:
	var new_index = (current_index + offset) % list.size()
	if new_index < 0:
		new_index = list.size() + new_index
	return new_index

## Returns the uid of a resource as a string.
static func uid_str(resource: Resource) -> String:
	return str(uid_int(resource))

static func uid_int(resource: Resource) -> int:
	return int(ResourceLoader.get_resource_uid(resource.resource_path))

static func load_uid_str(uid: String) -> Resource:
	return load_uid_int(int(uid))

static func load_uid_int(uid: int) -> Resource:
	return load(ResourceUID.get_id_path(uid))

static var smaller_axis_to_sides := {Vector2i.AXIS_X: [SIDE_LEFT, SIDE_RIGHT],
	Vector2i.AXIS_Y: [SIDE_TOP, SIDE_BOTTOM]}
