extends Control

@export_range(0, 1.0) var curve: float = 0.1 # 0 = straight line; 1 = arc where radius is (width / 2)
@export var rotate_children: bool = true
@export var separation: float = 8


func _ready() -> void:
	child_order_changed.connect(_update_children)
	_update_children()


func _update_children() -> void:
	var n := get_child_count()
	for i in n:
		var child := get_child(i) as Control
		var w := minf(size.x / n, child.size.x + separation)
		var x := (i + 0.5) * w
		x -= child.size.x / 2
		child.position = Vector2(x, 0)
