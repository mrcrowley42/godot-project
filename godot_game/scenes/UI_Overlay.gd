extends Sprite2D

@export var palletes:Array[Texture2D]
@export var i:int

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = palletes[i]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func cycle_forward():
	i = (i+1) % palletes.size()
	texture = palletes[i]
	$"../ColorRect".color = $"../ColorRect".colours[i]

func cycle_backwards():
	i = (i-1) % palletes.size()
	texture = palletes[i]
	$"../ColorRect".color = $"../ColorRect".colours[i]
