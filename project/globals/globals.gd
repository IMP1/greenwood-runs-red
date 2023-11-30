extends Node

@export var user_progress: MetaProgression
@export var campaign_progress: CampaignProgress
#@export var settings: UserSettings # TODO: Implement user settings


func _ready() -> void:
#	if UserSettings.is_existing_file():
#		settings = UserSettings.load_from_file()
#	else:
#		settings = UserSettings.new()
	if MetaProgression.is_existing_file():
		user_progress = MetaProgression.load_from_file()
	else:
		user_progress = MetaProgression.new()
	campaign_progress = null
	if CampaignProgress.is_existing_file():
		campaign_progress = CampaignProgress.load_from_file()


func _quit() -> void:
#	UserSettings.save_to_file(settings)
	MetaProgression.save_to_file(user_progress)
	if campaign_progress:
		CampaignProgress.save_to_file(campaign_progress)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit()
