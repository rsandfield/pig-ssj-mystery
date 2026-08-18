class_name LobbyPlayerData
extends RefCounted

const PROFILE_SCENE := preload("res://matchmaking/character_profile.tscn")

var info: PlayerInfo
var profile: CharacterProfile
var ready: bool:
	set(value):
		ready = value
		if profile:
			profile.set_ready(value)


func _init(i: PlayerInfo):
	info = i
	profile = PROFILE_SCENE.instantiate()
	profile.character_name = info.name()


func set_color(color: PlayerColor.Type):
	info.player_color = color
	profile.set_color(color)
