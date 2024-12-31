class_name TileHighlight
extends Node2D

var outlines: Array[PackedVector2Array]


func add_bitshape(bitshape: BitShape) -> void:
	add_tiles(bitshape.get_tiles())


func add_tiles(tiles: Array[Vector2i]) -> void:
	var points: PackedVector2Array
	for tile: Vector2i in tiles:
		points.append(Game.grid.tile_to_point(tile))
	add_points(points)


func add_points(points: PackedVector2Array) -> void:
	for point: Vector2 in points:
		outlines.append([
			point - Vector2(16, 0),
			point - Vector2(0, 8),
			point + Vector2(16, 0),
			point + Vector2(0, 8),
		] as PackedVector2Array)
	collapse()
	queue_redraw()


func collapse() -> void:
	if outlines.size() < 2: return
	
	var a: int = 0
	while a < outlines.size():
		var merge: bool = false
		
		var b: int = a + 1
		while b < outlines.size():
			var merged: Array[PackedVector2Array] = Geometry2D.merge_polygons(outlines[a], outlines[b])
			if outlines[a] == merged.front():
				b += 1
			else:
				outlines[a] = merged.pop_front()
				outlines.remove_at(b)
				outlines.append_array(merged)
				merge = true
		
		if not merge:
			a += 1



# internal

func _init() -> void:
	z_index = 1


func _draw() -> void:
	for outline: PackedVector2Array in outlines:
		draw_polyline(outline, Palette.WHITE)
		draw_line(outline[-1], outline[0], Palette.WHITE)
