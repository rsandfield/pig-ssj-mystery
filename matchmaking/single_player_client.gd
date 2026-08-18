class_name SinglePlayerClient
extends BaseMatchmakingClient


func connect_to_matchmaker(_username: String, _lobby_id: String = "") -> void:
	call_deferred("_emit_lobby_joined")


func _emit_lobby_joined() -> void:
	var local_data := MatchClient.local_player.to_dict()
	local_data["playerId"] = 1
	lobby_joined.emit("", 1, {"players": [local_data]})


func send_message(message: Dictionary) -> void:
	match message.get("event"):
		"player_joined":
			player_joined.emit(message.get("playerId"), message.get("data", {}))
		"player_disconnected":
			player_disconnected.emit(message.get("playerId"))
		"player_ready":
			message_recieved.emit(message)
			if message.get("ready"):
				message_recieved.emit({"event": "start_match", "players": []})
		"player_details_changed":
			message_recieved.emit(message)
		_:
			pass  # drop control-only events (e.g. control_set_max_players)
