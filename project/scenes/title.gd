extends Control

const CAMPAIGN_SCENE := preload("res://scenes/campaign.tscn") as PackedScene
const GAME_SCENE = preload("res://scenes/game_setup.tscn") as PackedScene
# const OPTIONS_SCENE = preload("res://scenes/options.tscn") as PackedScene
const CREDITS_SCENE = preload("res://scenes/credits.tscn") as PackedScene

var _last_run: CampaignProgress

@onready var _action_list := $Actions as Control
@onready var _continue_button := $Actions/Continue as Button
@onready var _current_campaign_info := $CurrentCampaign as Control
@onready var _current_campaign_name := $CurrentCampaign/Panel/Info/Name as Label
@onready var _current_campaign_level := $CurrentCampaign/Panel/Info/Level as Label
@onready var _current_campaign_portrait := $CurrentCampaign/Panel/Info/Portrait as TextureRect
@onready var _current_campaign_last_battle := $CurrentCampaign/Panel/Info/LastBattle as Label
@onready var _centre := $Centre as Control
@onready var _title := $Title as Label
@onready var _title_shadow := $Title/TitleShadow as Label


func _ready() -> void:
	_continue_button.visible = false
	_current_campaign_info.visible = false
	if Globals.campaign_progress:
		setup_current_run_info()


func setup_current_run_info():
	_continue_button.visible = true
	_current_campaign_info.visible = true
	_last_run = Globals.campaign_progress
	_current_campaign_name.text = "%s the %s" % [_last_run.player_name, _last_run.character.name]
	_current_campaign_portrait.texture = _last_run.character.portrait
	_current_campaign_level.text = "Level %d" % _last_run.level
	_current_campaign_last_battle.text = ""
	if _last_run.battle_results.size() > 0:
		var last_battle := _last_run.battle_results[_last_run.battle_results.size()-1]
		_current_campaign_last_battle.text = "Last Faced: %s" % last_battle.enemy.name


func _process(_delta: float) -> void:
	var mouse_pos := _centre.get_local_mouse_position()
	var parallax := 16 * mouse_pos / 640
	_title.position = -parallax + Vector2(0, 128)
	_title_shadow.position = parallax * 0.5


func _remove_menu() -> void:
	var duration := 0.6
	var stagger := 0.1
	var movement = size.x + _action_list.size.x
	var tween := create_tween()
	for i in _action_list.get_child_count():
		var button := _action_list.get_child(i) as Button
		var pos := button.position
		tween.parallel() \
			.tween_property(button, "position", Vector2(-movement, pos.y), duration) \
			.set_delay(stagger * i)
	await tween.finished


func _continue() -> void:
	await _remove_menu()
	var campaign := CAMPAIGN_SCENE.instantiate() as Campaign
	campaign.progress = _last_run
	SceneTransition.transition_to_scene(campaign)


func _new_game() -> void:
	await _remove_menu()
	SceneTransition.transition_to_packed(GAME_SCENE)


func _options() -> void:
	await _remove_menu()
#	SceneTransition.transition_to_packed(OPTIONS_SCENE)


func _credits() -> void:
	await _remove_menu()
	SceneTransition.transition_to_packed(CREDITS_SCENE)


func _quit():
	await _remove_menu()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
