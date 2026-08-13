@tool
class_name CharacterProfile
extends Control

@export var character_name = "Mr Green":
	set(value):
		character_name = value
		if _name_tag:
			_name_tag.text = value
@onready var _name_tag: Label = $Name
@export var _color: PlayerColor.Type


func _ready() -> void:
	character_name = character_name
	set_color(_color)


func set_color(color: PlayerColor.Type):
	_name_tag.modulate = PlayerColor.to_color(color)
