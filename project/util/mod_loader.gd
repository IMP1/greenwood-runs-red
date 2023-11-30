class_name ModResourceLoader
extends Object


static func _get_locations() -> PackedStringArray:
	var locations := PackedStringArray()
	var dir := DirAccess.open("res://data")
	dir.include_hidden = false
	dir.include_navigational = false
	for location in dir.get_directories():
		locations.append("res://data/%s" % location)
	dir = DirAccess.open("user://mods")
	dir.include_hidden = false
	dir.include_navigational = false
	for location in dir.get_directories():
		locations.append("user://mods/%s" % location)
	return locations


static func _occurrences(subpath: String) -> int:
	var count := 0
	for location in _get_locations():
		if ResourceLoader.exists("%s/%s" % [location, subpath]):
			count += 1
	return count


static func exists(subpath: String) -> bool:
	return _occurrences(subpath) >= 1


@warning_ignore("shadowed_global_identifier")
static func load(subpath: String) -> Resource:
	var occurrences := _occurrences(subpath)
	if occurrences == 0:
		push_error("[Mod Resource Loader] Couldn't find %s in any mod folder." % subpath)
		return null
	elif occurrences > 1:
		push_error("[Mod Resource Loader] Multiple instance of %s. Not sure which to load." % subpath)
		return null
	return ResourceLoader.load("res://data/core/%s" % subpath)

