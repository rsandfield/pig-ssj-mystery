class_name MatchmakingClient
extends Node

const MATCHMAKER_URL = "localhost:8080"
const SERVER_PORT = 8090


signal lobby_created(id: String)
signal lobby_disconnected()
signal lobby_joined(id: String, data: Dictionary)
signal player_joined(id: String, data: Dictionary)
signal player_disconnected(id: String)
signal message_recieved(data: Dictionary)


var ws: WebSocketPeer
var _player_id: int

func _init() -> void:
	ws = WebSocketPeer.new()


func _process(_delta: float) -> void:
	_try_connection()


func _try_connection():
	var old_state = ws.get_ready_state()
	ws.poll()
	var state = ws.get_ready_state()

	while ws.get_available_packet_count() > 0:
		var packet = ws.get_packet()
		var data = JSON.parse_string(packet.get_string_from_utf8())
		_handle_server_message(data)
	
	if state == WebSocketPeer.STATE_CLOSED:
		if old_state != WebSocketPeer.STATE_CLOSED:
			lobby_disconnected.emit()


func _handle_server_message(data: Dictionary):
	print("Server message: " + JSON.stringify(data))

	match data.get("event"):
		"lobby_created":
			_handle_lobby_created(data)
		"lobby_joined":
			_handle_lobby_joined(data)
		"player_joined":
			_handle_player_join(data)
		"player_disconnected":
			_handle_player_disconnected(data)
		_:
			message_recieved.emit(data)

	if data.has("event") and data.get("event") == "match_found":
		print("Match found! Joining server at: ", data.get("ip"))
		# Disconnect matchmaker and join game server
		ws.close()

func _handle_lobby_created(data: Dictionary):
	print("Lobby created: " + data.get("lobbyId"))
	lobby_created.emit(data.get("lobbyId"))

func _handle_lobby_joined(data: Dictionary):
	print("Lobby joined: " + data.get("lobbyId"))
	_player_id = data.get("playerId")
	lobby_joined.emit(data.get("lobbyId"), _player_id, data.get("data"))


func _handle_player_join(data: Dictionary):
	player_joined.emit(data.get("playerId"), data.get("data"))


func _handle_player_disconnected(data: Dictionary):
	player_disconnected.emit(data.get("playerId"))


func close() -> void:
	ws.close()


func connect_to_matchmaker(username: String, lobby_id: String = "") -> void:
	if lobby_id:
		lobby_id = "/" + lobby_id
	var query = username.uri_encode()
	var err = ws.connect_to_url("ws://" + MATCHMAKER_URL + '/lobbies/ws' + lobby_id + '?username=' + query)
	if err != OK:
		print("Failed to connect: ", err)
	else:
		print("Connecting to matchmaker...")


func send_message(message: Dictionary) -> void:
	ws.send_text(JSON.stringify(message))
