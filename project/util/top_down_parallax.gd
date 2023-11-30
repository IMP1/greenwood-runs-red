class_name OffsetParallaxLayer
extends ParallaxLayer

const BASE_FACTOR := 10

@export var centre: Vector2
@export var factor: float = 1


func _ready() -> void:
	_reset()


func _reset() -> void:
	var max_size := get_viewport_rect().size
	for child in get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		var offset := node.position - centre
		node.position += (offset * motion_scale * factor * BASE_FACTOR) / max_size


func set_centre(pos: Vector2) -> void:
	centre = pos
	_reset()
