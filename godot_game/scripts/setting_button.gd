extends TextureButton
@export var palettes: Array[Texture2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_down():
	%BtnClick.play()
	texture_pressed = load(texture_normal.resource_path.trim_suffix(".png") + "_pressed.png")
	%OptionsMenu.visible = !%OptionsMenu.visible
