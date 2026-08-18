extends Node

signal player_connected(peer_id: int, player_info)
signal player_disconnected(peer_id: int)
signal lobby_disconnected

const SERVER_PORT = 8090
const MATCHMAKER_ADDRESS = "http://127.0.0.1:8080" # IPv4 localhost
const MAX_CONNECTIONS = 20
const ICE_CONFIG = { "iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }] }
const GAME_SCENE_PATH = "res://match/game.tscn"

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players: Dictionary[int, PlayerInfo] = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var local_player: PlayerInfo = PlayerInfo.new()

var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_server():
	var peer = WebRTCMultiplayerPeer.new()
	var error = peer.create_server()
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[local_player.id] = local_player
	player_connected.emit(local_player.id, local_player)


func join_server(peer_id: int):
	var peer = WebRTCMultiplayerPeer.new()
	var error = peer.create_client(peer_id)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func add_peer(player: PlayerInfo, ws: WebSocketPeer):
	var connection: WebRTCPeerConnection = WebRTCPeerConnection.new()
	connection.initialize(ICE_CONFIG)

	connection.session_description_created.connect(_session_description_created(ws, connection, player.id))
	connection.ice_candidate_created.connect(_ice_candidate_created(ws, player.id))

	var peer = multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
	peer.add_peer(connection, player.peer_id)
	connection.create_offer()

	players[player.id] = player


func accept_peer(sender_id: int, ws: WebSocketPeer, offer_sdp: String):
	var connection := WebRTCPeerConnection.new()
	connection.initialize(ICE_CONFIG)
	var peer = multiplayer.multiplayer_peer as WebRTCMultiplayerPeer

	connection.session_description_created.connect(_session_description_created(ws, connection, sender_id))
	connection.ice_candidate_created.connect(_ice_candidate_created(ws, sender_id))
	
	peer.add_peer(connection, 1)
	connection.set_remote_description("offer", offer_sdp)


func add_ice(sender_id: int, media: String, index: int, n: String):
	var peer = multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
	var transport_id := players[sender_id].peer_id if multiplayer.is_server() else 1
	var connnection: WebRTCPeerConnection = peer.get_peer(transport_id)["connection"]
	connnection.add_ice_candidate(media, index, n)


func accept_answer(sender_id: int, sdp: String):
	var peer = multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
	var connnection: WebRTCPeerConnection = peer.get_peer(players[sender_id].peer_id)["connection"]
	connnection.set_remote_description("answer", sdp)


func _session_description_created(ws: WebSocketPeer, connection: WebRTCPeerConnection, target_id: int) -> Callable:
	return func(type, sdp):
		connection.set_local_description(type, sdp)
		ws.send_text(JSON.stringify(_handshake_message(target_id, {
			"type": type,
			"sdp": sdp
		})))


func _ice_candidate_created(ws: WebSocketPeer, target_id: int) -> Callable:
	return func(mid, index, n):
		ws.send_text(JSON.stringify(_handshake_message(target_id, {
			"type": "ice",
			"mid": mid,
			"index": index,
			"name": n

		})))


func _handshake_message(target_id: int, payload: Dictionary) -> Dictionary:
	var event = {
			"event": "player_rtc_handshake",
			"senderId": local_player.id,
			"targetId": target_id,
	}
	event.merge(payload)
	return event


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	var is_offline = multiplayer.multiplayer_peer is OfflineMultiplayerPeer
	if is_offline or multiplayer.is_server():
		players_loaded += 1
		var expected = players.values().filter(func(p): return !p.is_bot()).size()
		if players_loaded >= expected:
			$/root/Game.start_game()
			players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, local_player)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = local_player
	player_connected.emit(peer_id, local_player)


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	lobby_disconnected.emit()
