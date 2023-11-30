class_name CardAction
extends Resource

enum Target {
	NONE,
	ANY,
	ALL,
	SELF,
	ALLY,
	ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES,
}

@export var name: String
@export var icon: Texture
@export var subactions: Array[CardAction]
@export var target: Target

var target_battler: NodePath


func then(subaction: CardAction) -> CardAction:
	subactions.append(subaction)
	return self

