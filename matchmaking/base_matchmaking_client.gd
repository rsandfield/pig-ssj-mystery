class_name BaseMatchmakingClient
extends Node

signal lobby_created(id: String)
signal lobby_disconnected()
signal lobby_joined(id: String, player_id: int, data: Dictionary)
signal player_joined(id: String, data: Dictionary)
signal player_disconnected(id: String)
signal message_recieved(data: Dictionary)

# Only populated by MatchmakingClient; null in SinglePlayerClient
var ws: WebSocketPeer = null


func connect_to_matchmaker(_username: String, _lobby_id: String = "") -> void:
	pass


func send_message(_message: Dictionary) -> void:
	pass
