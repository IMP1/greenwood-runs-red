class_name EnemyBattlerInfo
extends VBoxContainer

const STATUS_ICON := preload("res://gui/status_icon.tscn")

@export var battler: Battler

@onready var _name := $Name as Label
@onready var _health := $Health/Bar as ProgressBar
@onready var _health_text := $Health/Value as Label
@onready var _energy := $HBoxContainer/Energy/Value as Label
@onready var _movement := $HBoxContainer/Movement/Value as Label
@onready var _evasion := $HBoxContainer/Evasion/Value as Label
@onready var _defence := $HBoxContainer/Defence/Value as Label
@onready var _status_list := $Statuses as Control


func _ready() -> void:
	if battler:
		refresh()


func refresh() -> void:
	_name.text = battler.character.name
	_health.max_value = battler.character.max_health
	_health.value = battler.health
	_health_text.text = "%d / %d" % [battler.health, battler.character.max_health]
	_energy.text = str(battler.energy)
	_movement.text = str(battler.movement)
	_evasion.text = str(battler.evasion)
	_defence.text = str(battler.defence)
	for child in _status_list.get_children():
		_status_list.remove_child(child)
		child.queue_free()
	for i in Status.StatusType.size():
		var status := Status.StatusType.values()[i] as Status.StatusType
		var amount := battler.get_status_level(status)
		if amount > 0:
			var icon := Status.get_icon(status)
			var status_icon := STATUS_ICON.instantiate() as StatusIcon
			status_icon.status = status
			status_icon.amount = amount
			status_icon.tooltip_text = Status.get_status_name(status)
			_status_list.add_child(status_icon)
			# TODO: Have a tooltip that shows where the total is coming from 
			#       (split up the instances of the same status) and how long it'll last

