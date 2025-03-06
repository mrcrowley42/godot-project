extends VBoxContainer

@onready var light_theme = load("res://themes/menu_btn_small.tres")
@onready var dark_theme = load("res://themes/menu_btn_dark.tres")

@onready var egg_list: EggList = load("res://resources/egg_list.tres")
@onready var baby_list: ResourceList = load("res://resources/baby_list.tres")
@onready var creature_list: ResourceList = load("res://resources/creature_list.tres")

@onready var creature_info_scene = load("res://scenes/UiScenes/creature_info.tscn")

@onready var egg_listing = load("res://scenes/UiScenes/egg_listing.tscn")
@onready var baby_listing = load("res://scenes/UiScenes/baby_listing.tscn")
@onready var creature_listing = load("res://scenes/UiScenes/creature_listing.tscn")

@export var grid_container: MarginContainer
@export var menu_btns_container: HBoxContainer

var selected_menu = 0

func _ready():
	update_menu_btns()
	
	## egg list
	for egg: EggEntry in egg_list.items:
		var button: Button = egg_listing.instantiate()
		button.icon = crop_img(egg.image)
		button.text = "\n" + egg.name
		grid_container.get_child(0).add_child(button)
	
	## baby list
	for baby: CreatureBaby in baby_list.items:
		var button: Button = baby_listing.instantiate()
		button.icon = baby.baby_part.sprite_frames.get_frame_texture('idle', 0)
		button.text = baby.name
		grid_container.get_child(1).add_child(button)

func crop_img(texture: Texture2D):
	var img: Image = texture.get_image()
	var used: Rect2i = img.get_used_rect()
	var reigon: Image = img.get_region(used)
	return ImageTexture.create_from_image(reigon)

func update_menu_btns():
	var i = 0
	for btn: Button in menu_btns_container.get_children():
		btn.theme = light_theme if i == selected_menu else dark_theme
		grid_container.get_child(i).visible = i == selected_menu
		i += 1

func _on_egg_button_down() -> void:
	selected_menu = 0
	update_menu_btns()

func _on_baby_button_down() -> void:
	selected_menu = 1
	update_menu_btns()

func _on_child_button_down() -> void:
	selected_menu = 2
	update_menu_btns()

func _on_adult_button_down() -> void:
	selected_menu = 3
	update_menu_btns()
