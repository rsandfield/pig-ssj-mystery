class_name PlayerInfo
extends RefCounted

enum Title {
	MR,
	MS,
	MRS,
	MX,
	DR,
	PROF,
	REV,
	SIR,
	DAME,
	LORD,
	LADY,
	PVT,
	SGT,
	LT,
	CAPT,
	MAJ,
	COL,
}

const BASIC_TITLES: Array[Title] = [
	Title.MR,
	Title.MS,
	Title.MRS,
	Title.MX,
]


var title: Title
var player_color: PlayerColor.Type
var player_id: int
var peer_id: int
var host: bool
var head: String
var body: String
var accessory: String


func to_dict() -> Dictionary:
	return {
		"name": name(),
		"title": title,
		"color": player_color,
		"playerId": player_id,
		"peerId": peer_id,
		"head": head,
		"body": body,
		"accessory": accessory
	}


static func from_dict(data: Dictionary) -> PlayerInfo:
	var p = PlayerInfo.new()
	p.title = Title.get(data.get("title"), "Mr")
	p.player_color = PlayerColor.from_string(data.get("color", "Red"))
	p.player_id = data.get("playerId")
	p.peer_id = data.get("peerId", -1)
	p.head = data.get("head", "")
	p.body = data.get("body", "")
	p.accessory = data.get("accessory", "")
	return p


func name() -> String:
	return "%s. %s" % [Title.keys()[title].capitalize(), PlayerColor.to_name(player_color)]


func color() -> Color:
	return PlayerColor.to_color(player_color)
