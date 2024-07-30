extends Label

@onready var debug_content = find_parent("DebugContent")
@onready var slider = find_child("slider")
@onready var progressing = find_child("progressing")
@onready var debug = find_child("debug")
@onready var t_div_disp = find_child("time_div_disp")

var dragging = false

func _process(_delta):
	text = str(debug_content.background.day_percent)
	progressing.button_pressed = debug_content.background.is_progressing
	if !dragging:
		slider.value = debug_content.background.day_percent
	else:
		manual_progress()

## when the slider is being dragged
func manual_progress():
	debug_content.background.change_day_progress(slider.value, true)
	text = str(slider.value)

func _on_day_progress_drag_ended(_value_changed):
	manual_progress()
	dragging = false


func _on_day_progress_drag_started():
	dragging = true


func _on_progressing_pressed():
	debug_content.background.is_progressing = progressing.button_pressed
	debug_content.background.update_time()


func _on_debug_pressed():
	debug_content.background.toggle_debug(debug.button_pressed)


func _on_time_div_value_changed(value):
	var v = max(1, value)
	debug_content.background.time_div = v
	debug_content.background.update_time()
	t_div_disp.text = 'x' + str(v)
