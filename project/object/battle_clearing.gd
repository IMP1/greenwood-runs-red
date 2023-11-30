class_name BattleClearing
extends Clearing

@export var background: Texture2D
@export var possible_encounters: Array[EnemyData]
@export var times_cleared: int = 0
@export_range(0.0, 1.0) var battle_probability: float = 1
