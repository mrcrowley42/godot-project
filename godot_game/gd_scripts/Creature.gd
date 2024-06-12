extends Sprite2D

@export_color_no_alpha var dying_colour;
var max_health: float = 1000.0
var max_mp: float = 1000.0
var health:float
var mp:float


# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = max_health
	self.mp = max_health

## function to damage/heal the Creature (use a negative value to heal)
func dmg(amount:float, stat:String):
	if stat == "hp":
		self.health -= amount
	elif stat == "mp":
		self.mp -= amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	 # Ensure health can't go below 0 or above the max health.
	health = clampf(health, 0, max_health)
	mp = clamp(mp, 0, max_mp)
	# Upon reaching 0 HP change the scene to dead scene.
	if health <= 0:
		call_deferred("dead")
	apply_dmg_tint()

	
func dead():
	get_tree().change_scene_to_file("res://scenes/dead.tscn")

## Tint the Create using the dying_colour set in inspector scaling the tint based on how low HP is.
func apply_dmg_tint():
	self.modulate.b = clampf(1 - (1 - self.health/1000) + dying_colour.b,0,1)
	self.modulate.g = clampf(1 - (1 - self.health/1000) + dying_colour.g,0,1)
	self.modulate.r = clampf(1 - (1 - self.health/1000) + dying_colour.r,0,1)
