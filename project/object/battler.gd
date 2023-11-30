class_name Battler
extends Node2D

@export var character: CharacterData
@export var health: int
@export var hand: Array[CardData]
@export var hand_size: int
@export var deck: Array[CardData]
@export var discard: Array[CardData]
@export var exhausted: Array[CardData]
@export var movement: int
@export var energy: int
@export var defence: int
@export var evasion: int
@export var statuses: Array[Status]

var prepared_actions: Array[CardAction]

@onready var _sprite := $Sprite as AnimatedSprite2D


func _ready() -> void:
	if not character.battler_sprite:
		push_error("Character %s has no battler sprite" % character.name)
	_sprite.sprite_frames = character.battler_sprite
	deck = character.deck.duplicate() as Array[CardData]
	hand_size = character.max_hand_size
	hand = []
	discard = []
	exhausted = []
	health = character.max_health
	energy = 0
	movement = 0
	prepared_actions = []
	# TODO: Apply start-of-battle modifiers


func _recycle_discard_pile() -> void:
	deck.append_array(discard)
	discard.clear()
	deck.shuffle()


func draw_card() -> void:
	if deck.is_empty():
		_recycle_discard_pile()
		if deck.is_empty():
			return
	hand.push_back(deck.pop_back())


func discard_hand() -> void:
	discard.append_array(hand)
	hand.clear()


func can_play_card(card: CardData) -> bool:
	if card.energy_cost > energy:
		return false
	# TODO: If enraged then can only use cards with attack actions and can't evade
	return true


func get_status_level(type: Status.StatusType) -> int:
	var count := 0
	for status in statuses:
		if status.type == type:
			count += status.amount
	return count

