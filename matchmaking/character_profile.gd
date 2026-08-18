@tool
class_name CharacterProfile
extends Control

@export var character_name = "Mr Green":
	set(value):
		character_name = value
		if _name_tag:
			_name_tag.text = value
@onready var _name_tag: Label = %Name
@export var _color: PlayerColor.Type
var _is_ready: bool
var _is_bot: bool


func _ready() -> void:
	character_name = character_name
	set_color(_color)


func set_head(i: int):
	%Head.texture = CharacterImageRegistry.get_head(i)


func set_body(i: int):
	%Body.texture = CharacterImageRegistry.get_body(i)
	%Accessory.texture = CharacterImageRegistry.get_accessory(i)


func set_color(color: PlayerColor.Type):
	_name_tag.modulate = PlayerColor.to_color(color)
	%Accessory.modulate = _name_tag.modulate


func set_ready(value: bool):
	_is_ready = value
	_modulate()


func set_bot(value: bool):
	_is_bot = value
	_modulate()


func _modulate():
	if _is_bot:
		%Ready.modulate = Color.BLUE
		return
	if _is_ready:
		%Ready.modulate = Color.GREEN
	else:
		%Ready.modulate = Color.RED
