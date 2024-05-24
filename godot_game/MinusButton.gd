extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_button_down():
	var hp = get_node("../../Player")
	
	
	hp.health -= 10
	
	#get_node("../../Player").health = clamp(get_node("../../Player").health,0, 100)
