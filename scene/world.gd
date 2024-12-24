extends Node2D

@export var tilemap: TileMapLayer


func _ready() -> void:
	Game.grid.generate(tilemap)
