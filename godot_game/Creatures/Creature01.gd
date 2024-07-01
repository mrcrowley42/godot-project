extends CharacterBody2D


var Sus = Stats.new()

func _ready():
	Sus.set_stats(1000, 1000, 1000, 1000)
	Sus.max_stats(1000, 1000, 1000, 1000)
	
	
func dmg(amount:float, stat:String):
	if stat == "Health":
		self.Health -= amount
	elif stat == "Hunger":
		self.Hunger -= amount
	elif stat == "Sleep": 
		self.Sleep -= amount
	elif stat == "Joy":
		self.Joy -= amount

func _process(_delta):
	 # Ensure health can't go below 0 or above the max health.
	self.Health = clampf(self.Health, 0, self.Max_Health)
	self.Huunger = clamp(self.Hunger, 0, self.Max_Hunger)
	# Upon reaching 0 HP change the scene to dead scene.
	if self.Health <= 0:
		call_deferred("Sus.dead")
	Sus.apply_dmg_tint()
