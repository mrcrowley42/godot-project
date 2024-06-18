extends Sprite2D

@export var palletes:Array[Texture2D]
@export var i:int

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = palletes[self.i]

func change_texture(addition=0):
	self.i = (self.i + addition) % palletes.size()
	texture = palletes[self.i]
	%ScreenColours.color = %ScreenColours.colours[self.i]
	%FoodButton.texture_normal = %FoodButton.palettes[self.i]
	%ActButton.texture_normal = %ActButton.palettes[self.i]
	%SettingButton.texture_normal = %SettingButton.palettes[self.i]
	

func cycle_forward():
	change_texture(1)

func cycle_backwards():
	change_texture(-1)

func save():
	return {"section": Globals.UI_SECTION, self.name: abs(self.i)}

func load(data):
	self.i = int(data[self.name])
	change_texture()
