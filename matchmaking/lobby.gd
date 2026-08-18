class_name Lobby
extends Control

static var _lobby_scene_prefab := preload("res://matchmaking/lobby.tscn")


@onready var _exit_lobby: Button = %ExitLobby
@onready var _ready_up: Button = %Ready
@onready var _lobby_id_label: Label = $LobbyID
@onready var _creator: CharacterCreator = $CharacterCreator

@onready var _players_ui = %Players

var _player_list: Dictionary[int, LobbyPlayerData] = {}
var _client: MatchmakingClient
var _lobby_id: String:
	set(value):
		_lobby_id = value
		_lobby_id_label.text = value


static func load(lobby_id: String = "") -> void:
	var lobby = _lobby_scene_prefab.instantiate()
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--username="):
			lobby.local_player["name"] = arg.split("=")[1]
			break
	lobby.init(lobby_id)

	var tree = Engine.get_main_loop()
	var old_scene = tree.current_scene
	
	tree.root.add_child(lobby)
	tree.current_scene = lobby

	if old_scene:
		old_scene.queue_free()


func init(lobby_id: String = ""):
	_client = MatchmakingClient.new()
	add_child(_client)

	_client.lobby_joined.connect(_set_lobby_data)
	_client.lobby_disconnected.connect(_lobby_disconnnected)
	_client.player_joined.connect(_player_connected)
	_client.player_disconnected.connect(_player_disconnected)
	_client.message_recieved.connect(_handle_message)

	if lobby_id:
		print("Joining lobby %s" % lobby_id)
		_client.connect_to_matchmaker(MatchClient.local_player.name(), lobby_id)
	else:
		print("Creating game")
		_client.connect_to_matchmaker(MatchClient.local_player.name())
		MatchClient.local_player.host = true


	MatchClient.player_connected.connect(_player_connected)
	MatchClient.player_disconnected.connect(_player_disconnected)


func _ready() -> void:
	_exit_lobby.pressed.connect(_on_exit_lobby)
	_ready_up.pressed.connect(_on_ready)
	_connect_character_creator()

	for p in _players_ui.get_children():
		p.queue_free()


func _connect_character_creator():
	_creator.title_changed.connect(_local_title_changed)
	_creator.color_changed.connect(_local_color_changed)
	_creator.head_changed.connect(_local_head_changed)
	_creator.body_changed.connect(_local_body_changed)


func _on_exit_lobby():
	get_tree().change_scene_to_file("res://main.tscn")


func _on_ready():
	var player: LobbyPlayerData = _player_list[MatchClient.local_player.player_id]
	player.ready = !player.ready
	_client.send_message({
		"event": "player_ready",
		"playerId": MatchClient.local_player.player_id,
		"lobbyId": _lobby_id,
		"ready": player.ready,
	})


func _set_lobby_data(lobby_id: String, player_id: int, data: Dictionary):
	print("Set lobby data")
	_lobby_id = lobby_id
	MatchClient.local_player.player_id = player_id
	var players = data.get("players", [])
	for player in players:
		_add_player_icon(player)


func _lobby_disconnnected():
	%Disconnected.visible = true


func _player_connected(id, player_data: Dictionary):
	print("Player %s connected: %s" % [id, player_data.get("name")])
	_add_player_icon(player_data)


func _add_player_icon(player_data: Dictionary):
	var i = PlayerInfo.from_dict(player_data)
	var p = LobbyPlayerData.new(i)
	_players_ui.add_child(p.profile)
	_player_list[player_data["playerId"]] = p
		

func _player_disconnected(id: int):
	print("Player %s disconnected" % id)
	_player_list[id].icon.queue_free()
	_player_list.erase(id)


func _local_color_changed(c: PlayerColor.Type):
	_client.send_message({
		"event": "player_details_changed",
		"playerId": MatchClient.local_player.player_id,
		"lobbyId": _lobby_id,
		"oldColor": PlayerColor.to_name(MatchClient.local_player.player_color),
		"newColor": PlayerColor.to_name(c),
	})


func _local_title_changed(title: PlayerTitle.Type):
	_client.send_message({
		"event": "player_details_changed",
		"playerId": MatchClient.local_player.player_id,
		"lobbyId": _lobby_id,
		"oldTitle": PlayerTitle.to_name(MatchClient.local_player.title),
		"newTitle": PlayerTitle.to_name(title),
	})


func _local_head_changed(index: int):
	_client.send_message({
		"event": "player_details_changed",
		"playerId": MatchClient.local_player.player_id,
		"lobbyId": _lobby_id,
		"oldHead": MatchClient.local_player.head,
		"newHead": index,
	})


func _local_body_changed(index: int):
	_client.send_message({
		"event": "player_details_changed",
		"playerId": MatchClient.local_player.player_id,
		"lobbyId": _lobby_id,
		"oldBody": MatchClient.local_player.body,
		"newBody": index,
	})


func _handle_message(msg: Dictionary):
	match msg.get("event"):
		# "lobby_joined":
		# 	_set_lobby_data(msg.get("lobbyId"), msg.get("playerId"), msg.get("data"))
		"player_details_changed":
			_handle_player_details_changed(msg)
		"player_color_change_rejected":
			_handle_player_color_change_rejected(msg)
		"player_ready":
			_handle_player_ready(msg)
		"start_match":
			_handle_match_start(msg)
		"player_rtc_handshake":
			_handle_rtc_handshake(msg)


func _handle_player_profile_changed(msg: Dictionary):
	var player_id = msg.get("playerId")
	var body = msg.get("newBody")
	if body:
		_player_list[player_id].info.body = body
	var head = msg.get("newHead")
	if head:
		_player_list[player_id].info.head = head
	var accessory = msg.get("newAccessory")
	if accessory:
		_player_list[player_id].info.accessory = accessory


func _handle_player_details_changed(msg: Dictionary):
	var player = _player_list[msg.get("playerId")]
	
	if msg.has("newTitle"):
		player.info.title = PlayerTitle.from_string(msg.get("newTitle"))
		player.profile.character_name = player.info.name()

	if msg.has("newBody"):
		player.info.body = msg.get("newBody")
		player.profile.set_body(player.info.body)
		player.profile.character_name = player.info.name()

	if msg.has("newHead"):
		player.info.head = msg.get("newHead")
		player.profile.set_head(player.info.head)
		player.profile.character_name = player.info.name()

	if !msg.has("newColor"):
		return
	var new_color := PlayerColor.from_string(msg.get("newColor"))
	if _color_is_available(new_color):
		player.set_color(new_color)
		player.profile.set_color(new_color)
		player.profile.character_name = player.info.name()
		return

	if MatchClient.local_player.host:
		var old_color = msg.get("oldColor")
		var player_id = msg.get("playerId")
		if !_color_is_available(old_color) && _player_list[player_id].info.player_color != old_color:
			old_color = _first_available_color()
		_client.send_message({
			"event": "player_color_change_rejected",
			"playerId": player_id,
			"lobbyId": _lobby_id,
			"oldColor": PlayerColor.to_name(old_color),
			"newColor": msg.get("newColor"),
		})
	

func _color_is_available(color: PlayerColor.Type) -> bool:
	for id in _player_list:
		var lobby_data = _player_list[id]
		if color == lobby_data.info.player_color:
			return false
	return true


func _first_available_color() -> PlayerColor.Type:
	var colors: Array[PlayerColor.Type] = []
	for id in _player_list:
		var lobby_data = _player_list[id]
		colors.append(lobby_data.info.player_color)
	for color in PlayerColor.Type.keys():
		if color not in colors:
			return color
	return PlayerColor.Type.RED


func _handle_player_color_change_rejected(msg: Dictionary):
	var color = PlayerColor.from_string(msg.get("oldColor"))
	_player_list[msg.get("playerId")].set_color(color)


func _handle_player_ready(msg: Dictionary):
	var id = msg.get("playerId") as int
	_player_list[id].ready = msg.get("ready") as bool


func _handle_match_start(msg: Dictionary):
	if MatchClient.local_player.host:
		for player_data in msg.get("players", []):
			var player_id: int = player_data.get("playerId")
			if player_id == MatchClient.local_player.id:
				continue
			var player_info := PlayerInfo.from_dict(player_data)
			player_info.peer_id = player_data.get("peerId")
			MatchClient.add_peer(player_info, _client.ws)
	else:
		for info in msg.get("players", []):
			if info.get("playerId") == MatchClient.local_player.id:
				MatchClient.join_server(info.get("peerId"))


func _handle_rtc_handshake(msg: Dictionary):
	if msg.get("targetId") != MatchClient.local_player.id:
		return

	var sender_id = msg.get("senderId")
	match msg.get("type"):
		"ice":
			MatchClient.add_ice(sender_id, msg.get("mid"), msg.get("index"), msg.get("name"))
			return
		"answer":
			MatchClient.accept_answer(sender_id, msg.get("sdp"))
		_:
			MatchClient.accept_peer(sender_id, _client.ws, msg.get("sdp"))
