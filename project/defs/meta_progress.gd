class_name MetaProgression
extends Resource

const FILEPATH := "user://.progress"

@export var available_characters: Array[String] = ["fox", "badger", "owl"]


static func save_to_file(progress: MetaProgression) -> void:
	ResourceSaver.save(progress, FILEPATH)


static func load_from_file() -> MetaProgression:
	return ResourceLoader.load(FILEPATH) as MetaProgression


static func is_existing_file() -> bool:
	return ResourceLoader.exists(FILEPATH)
