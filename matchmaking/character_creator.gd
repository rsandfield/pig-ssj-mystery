class_name CharacterCreator
extends Control


signal title_changed(title: PlayerTitle.Type)
signal color_changed(color: PlayerColor.Type)
signal head_changed(index: int)
signal body_changed(index: int)

const HEAD_DATA_PATH = "res://assets/characters/heads/"
const BODY_DATA_PATH = "res://assets/characters/bodies/"

@onready var title_dropdown: OptionButton = %Title
@onready var color_dropdown: OptionButton = %Color

@onready var head_left: Button = %Head/Left
@onready var head_right: Button = %Head/Right
@onready var head_image: TextureRect = %Head/Primary

@onready var body_left: Button = %Body/Left
@onready var body_right: Button = %Body/Right
@onready var body_image: TextureRect = %Body/Primary
@onready var body_color: TextureRect = %Body/Accessory

var _titles: Array[PlayerTitle.Type] = []

var _head_index = 0
var _body_index = 0


func _ready():
	_setup_buttons()
	_populate_dropdowns()


func _setup_buttons():
	head_left.pressed.connect(_cycle_head.bind(-1))
	head_right.pressed.connect(_cycle_head.bind(1))
	body_left.pressed.connect(_cycle_body.bind(-1))
	body_right.pressed.connect(_cycle_body.bind(1))


func _populate_dropdowns():
	title_dropdown.item_selected.connect(_set_title)
	title_dropdown.clear()
	for i in PlayerTitle.BASIC:
		_titles.append(i)
		title_dropdown.add_item(PlayerTitle.Type.keys()[i].capitalize())

	color_dropdown.item_selected.connect(_set_color)
	color_dropdown.clear()
	for color in PlayerColor.Type.keys():
		color_dropdown.add_item(color.capitalize())


func _set_title(i: int):
	title_changed.emit(PlayerTitle.Type.values()[_titles[i]])


func _set_color(i: int):
	var player_color := PlayerColor.from_int(i)
	body_color.modulate = PlayerColor.to_color(player_color)
	color_changed.emit(player_color)


func _cycle_head(i: int):
	_head_index += i
	head_image.texture = CharacterImageRegistry.get_head(_head_index)
	head_changed.emit(_head_index)


func _cycle_body(i: int):
	_body_index += i
	body_image.texture = CharacterImageRegistry.get_body(_body_index)
	body_color.texture = CharacterImageRegistry.get_accessory(_body_index)
	body_changed.emit(_body_index)
