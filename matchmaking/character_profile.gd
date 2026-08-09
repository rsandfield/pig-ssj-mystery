@tool
class_name CharacterProfile
extends Control

@export var character_name = "Mr Green":
	set(value):
		character_name = value
		_name_tag.text = value
@onready var _name_tag: Label = $Name
