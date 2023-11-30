class_name CharacterOptionButton
extends Button

@export var texture: Texture2D
@export var character_name: String
@export var colour: Color

@onready var _label := $Label as Label


func _ready() -> void:
	icon = texture
	_label.text = character_name
	for button_mode in ["normal", "hover", "pressed"]:
		var style := get("theme_override_styles/%s" % button_mode) as StyleBoxFlat
		style.bg_color = colour
		style.bg_color.a = 192
