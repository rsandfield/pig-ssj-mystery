class_name LobbyPlayerData
extends RefCounted

var name: String
var icon: Texture2D
var ready: bool

func _init(n: String, i: Texture2D):
    name = n
    icon = i