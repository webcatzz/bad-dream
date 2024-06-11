class_name TileHighlight extends Area2D
## Bare-bones tile highlighter.


var polygon: PackedVector2Array


static func node() -> TileHighlight:
	return preload("res://node/tile_highlight.tscn").instantiate()


## Sets the highlighted area according to a [BitMap].
func from_bitmap(bitmap: BitMap) -> void:
	if not bitmap.get_size(): return
	
	polygon = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, bitmap.get_size()), 0)[0]
	
	for i: int in polygon.size():
		polygon[i] = Vector2(Iso.from_grid(polygon[i]))


## Sets the highlighted area according to a [BitShape].
func from_bitshape(bitshape: BitShape) -> void:
	from_bitmap(bitshape)
	position = Iso.from_grid(bitshape.offset) - Vector2(16, 0)


## Sets the highlighted area according to a [BitPath].
func from_bitpath(bitpath: BitPath) -> void:
	bitpath.update()
	from_bitmap(bitpath)
	global_position = Vector2(32, -24) - Iso.from_grid(bitpath.get_size()) + Vector2(32 * bitpath.spill, 0)


## Sets the highlighted area according to a [PackedVector2Array] of points.
func from_polygon(polygon: PackedVector2Array) -> void:
	self.polygon = polygon



# internal

func _ready() -> void:
	self.monitorable = false
	$Fill.polygon = polygon
	$Collision.polygon = polygon


var _time: float = 0
func _process(delta: float) -> void:
	_time += delta
	$Fill.texture_rotation = sin(_time / 240) * 180
