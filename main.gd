extends Control


@onready var _start_game: Button = %StartGame
@onready var _join_game: Button = %JoinGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_game.pressed.connect(_start_game_pressed)
	_join_game.pressed.connect(_join_game_pressed)


func _start_game_pressed() -> void:
	pass


func _join_game_pressed() -> void:
	pass
