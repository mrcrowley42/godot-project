extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		$"../PIPE".play()
		$"../Player".health -= 50
		queue_free()
		
