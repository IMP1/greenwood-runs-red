class_name Modal
extends ColorRect

@export var close_on_click_outside: bool = true

var _current_open_child: Control


func _ready() -> void:
	visible = false


func show_menu(child_path: String) -> void:
	if _current_open_child:
		_current_open_child.visible = false
	if not has_node(child_path):
		push_error("Modal has no child '%s'" % child_path)
		return
	_current_open_child = get_node(child_path) as Control
	_current_open_child.visible = true
	visible = true


func hide_all() -> void:
	if _current_open_child:
		_current_open_child.visible = false
		_current_open_child = null
	visible = false


func _gui_input(event: InputEvent) -> void:
	if not close_on_click_outside:
		return
	if not event is InputEventMouseButton:
		return
	hide_all()

