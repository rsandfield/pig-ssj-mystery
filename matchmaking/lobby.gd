class_name Lobby
extends Control

@onready var _exit_lobby: Button = %ExitLobby
@onready var _ready_up: Button = %Ready
@onready var _players = %Players

var _player_list: Dictionary[int, LobbyPlayerData] = {}


func _ready() -> void:
	_exit_lobby.pressed.connect(_on_exit_lobby)
	_ready_up.pressed.connect(_on_ready)


func _on_exit_lobby():
	pass


func _on_ready():
	pass
