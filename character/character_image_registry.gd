class_name CharacterImageRegistry

const HEAD_DATA_PATH = "res://assets/characters/heads/"
const BODY_DATA_PATH = "res://assets/characters/bodies/"

var _heads: Array[Texture2D] = []
var _primaries: Array[Texture2D] = []
var _accessories: Array[Texture2D] = []

static var _instance: CharacterImageRegistry


func _init():
	_populate_images()


func _populate_images():
	for file_name in ResourceLoader.list_directory(HEAD_DATA_PATH):
		if file_name.ends_with(".png"):
			_heads.append(load(HEAD_DATA_PATH + "/" + file_name))
	
	for folder_name in ResourceLoader.list_directory(BODY_DATA_PATH):
		var folder_path = BODY_DATA_PATH + "/" + folder_name + "/"
		_primaries.append(load(folder_path + "/primary.png"))
		_accessories.append(load(folder_path + "/accessory.png"))


static func get_head(index: int) -> Texture2D:
	if !_instance:
		_instance = CharacterImageRegistry.new()
	return _instance._heads[index % len(_instance._heads)]


static func get_body(index: int) -> Texture2D:
	if !_instance:
		_instance = CharacterImageRegistry.new()
	return _instance._primaries[index % len(_instance._primaries)]


static func get_accessory(index: int) -> Texture2D:
	if !_instance:
		_instance = CharacterImageRegistry.new()
	return _instance._accessories[index % len(_instance._accessories)]
