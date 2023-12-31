class_name PlayerBattlerInfo
extends VBoxContainer

const STATUS_ICON := preload("res://gui/status_icon.tscn")

@export var player_name: String
@export var player: Battler

@onready var _name := $Name as Label
@onready var _health := $Health/Bar as ProgressBar
@onready var _health_text := $Health/Value as Label
@onready var _energy := $HFlowContainer/Energy/Value as Label
@onready var _movement := $HFlowContainer/Movement/Value as Label
@onready var _evasion := $HFlowContainer/Evasion/Value as Label
@onready var _defence := $HFlowContainer/Defence/Value as Label
@onready var _status_list := $Statuses as Control
@onready var _hand_size := $Card/Hand/Label as Label
@onready var _deck_size := $Card/Deck/Label as Label
@onready var _discard_size := $Card/Discard/Label as Label


func refresh() -> void:
	_name.text = player_name
	_health.max_value = player.character.max_health
	_health.value = player.health
	_health_text.text = "%d / %d" % [player.health, player.character.max_health]
	_energy.text = str(player.energy)
	_movement.text = str(player.movement)
	_evasion.text = str(player.evasion)
	_defence.text = str(player.defence)
	_hand_size.text = str(player.hand.size())
	_deck_size.text = str(player.deck.size())
	_discard_size.text = str(player.discard.size())
	for child in _status_list.get_children():
		_status_list.remove_child(child)
		child.queue_free()
	for i in Status.StatusType.size():
		var status := Status.StatusType.values()[i] as Status.StatusType
		var amount := player.get_status_level(status)
		if amount > 0:
			var icon := Status.get_icon(status)
			var status_icon := STATUS_ICON.instantiate() as StatusIcon
			status_icon.status = status
			status_icon.amount = amount
			status_icon.tooltip_text = Status.get_status_name(status)
			_status_list.add_child(status_icon)
			# TODO: Have a tooltip that shows where the total is coming from 
			#       (split up the instances of the same status) and how long it'll last

