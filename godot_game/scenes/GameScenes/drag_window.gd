extends TextureRect

#var drag_pos = null

var dragging: bool = false
var offset = Vector2i(0, 0)
@onready var window: Window = get_window()

func _process(delta):
	if dragging:
		window.position = DisplayServer.mouse_get_position()  - Vector2i(offset)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var container_rect = Rect2(self.position, self.size)
		if container_rect.has_point(event.position):
			dragging = true
			offset = position
			offset = get_global_mouse_position()
	if event is InputEventMouseButton and not event.pressed:
		dragging = false
	#if dragging and event is InputEventMouseMotion:
		#
		#var rand = RandomNumberGenerator.new()
#
		#var width = rand.randi_range(0, 1920- window.size.x)
		#var height = rand.randi_range(0, 1080 - window.size.y)
		#window.position = Vector2(width, height)
		#window.position += Vector2i(event.relative)

#func _on_gui_input(event):
	#if event is InputEventMouseButton:
		##if event.pressed:
		#var window_location: Vector2i = get_window().position
		#var mouse_location: Vector2i = DisplayServer.mouse_get_position()
		#print(mouse_location-window_location)
			#print(get_window().get_position_with_decorations())
			#print(DisplayServer.mouse_get_position())
			#var rand = RandomNumberGenerator.new()

			#var width = rand.randi_range(0, 1920- get_window().size.x)
			#var height = rand.randi_range(0, 1080 - get_window().size.y)
			
			
			#get_window().position = Vector2(width, height)
			
			
		
