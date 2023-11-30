class_name CharacterData
extends Resource

@export var name: String
@export var portrait: Texture2D
@export var colour: Color
@export var max_health: int = 10
@export var energy_per_turn: int = 3
@export var max_hand_size: int = 5
@export var deck: Array[CardData]
@export var battler_sprite: SpriteFrames
# TODO: Modifiers


static func get_all() -> Array[CharacterData]:
	var enemies: Array[CharacterData] = []
	for path in get_all_filepaths():
		enemies.append(load(path) as CharacterData)
	return enemies


static func get_all_filepaths() -> PackedStringArray:
	var paths := PackedStringArray()
	var mods := PackedStringArray()
	mods.append("res://data/core/characters")
	DirAccess.make_dir_absolute("user://mods")
	var mods_dir := DirAccess.open("user://mods")
	mods_dir.include_navigational = false
	mods_dir.include_hidden = false
	for dir in mods_dir.get_directories():
		mods.append("user://mods/" + dir + "/characters")
	for path in mods:
		var dir := DirAccess.open(path)
		if dir:
			dir.include_navigational = false
			dir.list_dir_begin()
			var file_name := dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					paths.append(path + "/" + file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
	return paths
