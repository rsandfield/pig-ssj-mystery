extends Control


@onready var _single_player: Button = %SinglePlayer
@onready var _new_lobby: Button = %NewLobby
@onready var _join_game: Button = %JoinGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_single_player.pressed.connect(_single_player_pressed)
	_new_lobby.pressed.connect(_new_lobby_pressed)
	_join_game.pressed.connect(_join_game_pressed)


func _single_player_pressed() -> void:
	Lobby.load_single_player()


func _new_lobby_pressed() -> void:
	Lobby.load()


func _join_game_pressed() -> void:
	pass
