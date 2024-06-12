extends Label


var og_text = self.text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = og_text % [str(%Creature.health), str(%StatusManager.hp_rate)]
