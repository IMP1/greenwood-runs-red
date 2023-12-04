class_name StatusIcon
extends TextureRect

@export var status: Status.StatusType
@export var amount: int

@onready var label := $Label as Label


func _ready() -> void:
	texture = Status.get_icon(status)
	label.text = str(amount)
