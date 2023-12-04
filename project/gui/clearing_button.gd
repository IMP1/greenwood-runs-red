class_name ClearingButton
extends Control

signal clearing_selected

@export var player: CampaignProgress
@export var clearing: Clearing

@onready var _open_button := $OpenInfo as Button
@onready var _close_button := $ClearingInfo/CloseInfo as Button
@onready var _visit_button := $ClearingInfo/Enter as Button
@onready var _clearing_info := $ClearingInfo as Control
@onready var _clearing_icon := $ClearingInfo/ClearingType as TextureRect
@onready var _clearing_name := $ClearingInfo/ClearingName as Label
@onready var _clearing_text := $ClearingInfo/DifficultyLevel as Label


func _ready() -> void:
	_open_button.pressed.connect(_show_info)
	_close_button.pressed.connect(_hide_info)
	_visit_button.pressed.connect(func(): clearing_selected.emit())
	_hide_info()


func _calculate_difficulty() -> String:
	# TODO: Determine difficulty (range) of clearing
	var battle_clearing := clearing as BattleClearing
	var difference := battle_clearing.possible_encounters.map(func(e: EnemyData) -> int: return e.experience_awarded)
	print("[Clearing Button] %s" % str(difference))
	var difficulty := "Easy"
	return difficulty


func _show_info() -> void:
	_clearing_name.text = clearing.clearing_name
	_clearing_text.text = "" # QUESTION: What is this for non-battle clearings?
	if clearing is BattleClearing:
		_clearing_text.text = _calculate_difficulty()
	_clearing_icon.texture = clearing.icon
	_open_button.visible = false
	_clearing_info.visible = true


func _hide_info() -> void:
	_clearing_info.visible = false
	_open_button.visible = true

