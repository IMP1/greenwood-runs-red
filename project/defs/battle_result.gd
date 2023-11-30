class_name BattleResult
extends Resource

@export var enemy: EnemyData
@export var chosen_reward_card: CardData
@export var chosen_reward_modifier: String # TODO: Change to be a Modifier

@export var turn_duration: int
@export var damage_suffered: int
@export var damage_dealt: int
@export var distance_moved: int
@export var energy_spent: int
@export var distance_evaded: int
@export var attacks_made: int
# TODO: etc.

