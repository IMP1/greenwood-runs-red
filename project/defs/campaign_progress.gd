class_name CampaignProgress
extends Resource

const DEFAULT_SAVE_FILEPATH := "user://saves/save_0.tres"

@export var player_name: String
@export var character: CharacterData
@export var experience: int = 0
@export var level: int = 1
@export var battle_results: Array[BattleResult] = []
@export var current_clearing: NodePath = ""
@export var visited_clearings: Array[NodePath] = []
@export var cleared_clearings: Array[NodePath] = []


static func save_to_file(progress: CampaignProgress, path:="") -> void:
	if path.is_empty():
		path = DEFAULT_SAVE_FILEPATH
	DirAccess.make_dir_absolute("user://saves")
	var result := ResourceSaver.save(progress, path)
	if result != OK:
		push_error("Error saving progress: %d" % result)


static func load_from_file(path:="") -> CampaignProgress:
	if path.is_empty():
		path = DEFAULT_SAVE_FILEPATH
	return ResourceLoader.load(path) as CampaignProgress


static func is_existing_file(path:="") -> bool:
	if path.is_empty():
		path = DEFAULT_SAVE_FILEPATH
	return ResourceLoader.exists(path)
