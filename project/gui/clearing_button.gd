class_name ClearingButton
extends Control

signal clearing_selected

@export var clearing: Clearing

@onready var _open_button := $OpenInfo as Button
@onready var _close_button := $ClearingInfo/CloseInfo as Button
@onready var _visit_button := $ClearingInfo/Enter as Button
@onready var _clearing_info := $ClearingInfo as Control
@onready var _clearing_icon := $ClearingInfo/ClearingType as TextureRect
@onready var _clearing_name := $ClearingInfo/ClearingName as Label


func _ready() -> void:
	_open_button.pressed.connect(_show_info)
	_close_button.pressed.connect(_hide_info)
	_visit_button.pressed.connect(func(): clearing_selected.emit())
	_hide_info()


func _show_info() -> void:
	_clearing_name.text = clearing.clearing_name
	_clearing_icon.texture = clearing.icon
	_open_button.visible = false
	_clearing_info.visible = true


func _hide_info() -> void:
	_clearing_info.visible = false
	_open_button.visible = true

