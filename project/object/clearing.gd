class_name Clearing
extends Node2D

signal visited

@export var clearing_name: String = "Clearing"
@export var icon: Texture2D
@export var adjacent_clearings: Array[Clearing]
@export var times_visited: int = 0
