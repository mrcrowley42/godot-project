extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func collide():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_body_entered(body):
	if body.is_in_group("player"):
		call_deferred("collide")
		
