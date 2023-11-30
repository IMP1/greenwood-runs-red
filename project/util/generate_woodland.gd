extends Node2D

const BOTTOM_NAME := "Bottom"
const MIDDLE_NAME := "Middle"
const TOP_NAME := "Top"

@export var bottom_texture: Texture2D
@export var middle_texture: Texture2D
@export var top_texture: Texture2D
@export var offset_factor: float = 1.0 / 20
@export var max_offset: float = 32


func generate_woodland() -> void:
	for child in get_children():
		var s := randf_range(0.9, 1.1)
		var size := Vector2(s, s)
		var bottom := Sprite2D.new()
		bottom.name = BOTTOM_NAME
		bottom.texture = bottom_texture
		bottom.z_index = 0
		child.add_child(bottom)
		bottom.set_deferred("rotation", randf_range(0.0, TAU))
		bottom.set_deferred("scale", size)
		var middle := Sprite2D.new()
		middle.name = MIDDLE_NAME
		middle.texture = middle_texture
		middle.z_index = 1
		child.add_child(middle)
		middle.set_deferred("rotation", randf_range(0.0, TAU))
		middle.set_deferred("scale", scale)
		var top := Sprite2D.new()
		top.name = TOP_NAME
		top.texture = top_texture
		top.z_index = 2
		child.add_child(top)
		top.set_deferred("rotation", randf_range(0.0, TAU))
		top.set_deferred("scale", scale)
	await get_tree().process_frame


func _process(_delta: float) -> void:
	for child in get_children():
		var tree := child as Node2D
		var top := tree.get_node(TOP_NAME) as Sprite2D
		var middle := tree.get_node(MIDDLE_NAME) as Sprite2D
		var bottom := tree.get_node(BOTTOM_NAME) as Sprite2D
		var centre := get_viewport().get_camera_2d().get_screen_center_position()
		var offset := (centre - tree.global_position) * offset_factor
		var dist := offset.length()
		dist = clampf(dist, -max_offset, max_offset)
		offset = offset.normalized() * dist
		bottom.position = -offset / 100
		middle.position = -offset / 2
		top.position = -offset
