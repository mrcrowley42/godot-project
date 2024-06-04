extends Sprite2D
var health: float = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		call_deferred("dead")
	self.modulate.b = 1 - (1 - self.health/1000)
	self.modulate.g = 1 - (1 - self.health/1000)
	self.modulate.r = 1 
	
func _on_health_timer_tick():
	self.health -= 5
	
func dead():
	get_tree().change_scene_to_file("res://dead.tscn")

	
