class_name TileHighlight extends Node2D


func add_polygon(polygon: PackedVector2Array) -> void:
	var node: Node2D = preload("res://node/tile_highlight_polygon.tscn").instantiate()
	node.get_child(0).polygon = polygon
	node.get_child(1).points = polygon
	add_child(node)


func from_bitshape(bitshape: BitShape) -> void:
	for polygon: PackedVector2Array in bitshape.to_polygons():
		add_polygon(polygon)



# internal

func _init() -> void:
	z_index = -1
