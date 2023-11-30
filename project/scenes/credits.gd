extends Control

@export var scroll_speed: float = 128

var _is_paused: bool = false

@onready var scroll_container := $ScrollContainer as ScrollContainer


func _process(delta: float) -> void:
	if _is_paused:
		return
	scroll_container.scroll_vertical -= int(scroll_speed * delta)


func _back() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/title.tscn"))
