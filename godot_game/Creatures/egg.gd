extends Node2D
@onready var cracker = %eggTimer
@export var set_wait: float

func party_time():
	pass


func load_timer():
	var time = Timer.new()
	time.autostart = false
	time.one_shot = true
	time.wait_time = 2
	time.timeout.connect(func():
		get_tree().change_scene("res://scenes/prototype.tscn"))
	



func _enter_tree():
	%lilGuy.visible = false
	%eggSprite.visible = true
	%eggTimer.wait_time = set_wait

func _ready():
	cracker.timeout.connect(func():
		print("done")
		%Yip.play()
		%eggSprite.visible = false
		%lilGuy.visible = true
		load_timer()
		)


