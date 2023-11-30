class_name CardGui
extends Control

signal pressed

@export var data: CardData
@export var disabled: bool:
	set = _set_disabled

@onready var _title := $Button/Title as Label
@onready var _energy_cost := $Button/Contents/EnergyCost as Label
@onready var _exhaustion := $Button/ExhaustIcon as TextureRect
@onready var _texture := $Button/Contents/TextureRect as TextureRect
@onready var _action_list := $Button/Actions as VBoxContainer
@onready var _button := $Button as Button


func _set_disabled(val: bool) -> void:
	disabled = val
	if _button:
		_button.disabled = disabled


func _ready() -> void:
	_title.text = data.name
	_energy_cost.text = str(data.energy_cost)
	_exhaustion.visible = data.is_exhausted
	_button.disabled = disabled
	if data.background_texture:
		_texture.texture = data.background_texture
	for action in data.actions:
		var label := Label.new()
		_action_list.add_child(label)
		label.set_deferred("text", action.name)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.set_deferred("theme_override_font_sizes/font_size", 16)


func _pressed() -> void:
	pressed.emit()
