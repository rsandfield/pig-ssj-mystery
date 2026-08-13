class_name LobbyPlayerData
extends RefCounted

const _profile_scene := preload("res://matchmaking/character_profile.tscn")

var info: PlayerInfo
var profile: CharacterProfile
var ready: bool

func _init(i: PlayerInfo):
    info = i
    profile = _profile_scene.instantiate()
    profile.name = info.name()


func set_color(color: PlayerColor.Type):
    info.player_color = color
    profile.set_color(color)