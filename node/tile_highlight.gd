class_name TileHighlight extends Node2D


func add_tile(tile: Vector2i) -> void:
	var node: Node2D = preload("res://node/tile_highlight_tile.tscn").instantiate()
	node.position = Iso.from_grid(tile)
	add_child(node)


func from_bitshape(bitshape: BitShape) -> void:
	for x: int in bitshape.get_size().x: for y: int in bitshape.get_size().y:
		if bitshape.get_bit(x, y):
			add_tile(Vector2i(x, y))
