class_name EnemyData
extends CharacterData

@export var card_rewards: Dictionary
# TODO: modifier rewards
@export var experience_awarded: int = 0
@export var min_char_level: int = -1
@export var max_char_level: int = -1


static func get_all_enemies() -> Array[EnemyData]:
	var enemies: Array[EnemyData] = []
	for path in get_all_filepaths():
		enemies.append(load(path) as EnemyData)
	return enemies


static func get_all_filepaths() -> PackedStringArray:
	var paths := PackedStringArray()
	var mods := PackedStringArray()
	mods.append("res://data/core/enemies")
	DirAccess.make_dir_absolute("user://mods")
	var mods_dir := DirAccess.open("user://mods")
	mods_dir.include_navigational = false
	mods_dir.include_hidden = false
	for dir in mods_dir.get_directories():
		mods.append("user://mods/" + dir + "/enemies")
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
