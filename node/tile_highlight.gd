class_name TileHighlight extends Node2D


func add_polygon(polygon: PackedVector2Array) -> void:
	var node: Node2D = preload("res://node/tile_highlight_polygon.tscn").instantiate()
	node.get_child(0).polygon = polygon
	node.get_child(1).points = polygon
	add_child(node)


func from_bitshape(bitshape: BitShape) -> void:
	position += Iso.from_grid(bitshape.offset)
	
	for polygon: PackedVector2Array in bitshape.opaque_to_polygons(Rect2i(Vector2i.ZERO, bitshape.get_size()), 0):
		for i: int in polygon.size():
			polygon[i] = Iso.from_grid(polygon[i])
		
		add_polygon(polygon)



# internal

func _init() -> void:
	position.x = -16
	z_index = -1
