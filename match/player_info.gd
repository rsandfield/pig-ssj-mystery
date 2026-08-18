class_name PlayerInfo
extends RefCounted


var title: PlayerTitle.Type
var player_color: PlayerColor.Type
var player_id: int
var peer_id: int
var host: bool
var head: int
var body: int


func to_dict() -> Dictionary:
	return {
		"name": name(),
		"title": PlayerTitle.to_name(title),
		"color": PlayerColor.to_name(player_color),
		"playerId": player_id,
		"peerId": peer_id,
		"head": head,
		"body": body,
	}


static func from_dict(data: Dictionary) -> PlayerInfo:
	var p := PlayerInfo.new()
	p.title = PlayerTitle.from_string(data.get("title", "MR"))
	p.player_color = PlayerColor.from_string(data.get("color", "Red"))
	p.player_id = data.get("playerId")
	p.peer_id = data.get("peerId", -1)
	p.head = data.get("head", 0)
	p.body = data.get("body", 0)
	return p


func name() -> String:
	return "%s. %s" % [PlayerTitle.to_name(title), PlayerColor.to_name(player_color)]


func color() -> Color:
	return PlayerColor.to_color(player_color)


func is_bot() -> bool:
	return player_id < 0
