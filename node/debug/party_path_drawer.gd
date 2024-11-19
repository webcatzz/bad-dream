extends Node2D


func _ready() -> void:
	z_index = 1


func _draw() -> void:
	if Game.party_node:
		for point: Vector2 in Game.party_node.path:
			draw_circle(point, 4, Color.RED)


func _process(_delta: float) -> void:
	queue_redraw()
