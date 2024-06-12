class_name TileHighlight extends Area2D
## Bare-bones tile highlighter.


## Returns the class's associated [PackedScene].
static func node() -> TileHighlight:
	return preload("res://node/tile_highlight.tscn").instantiate()



# setting area

## Sets the highlighted area according to a [PackedVector2Array] of points.
func from_polygon(polygon: PackedVector2Array) -> void:
	$Fill.polygon = polygon
	$Collision.polygon = polygon


## Sets the highlighted area according to a [BitMap].
func from_bitmap(bitmap: BitMap) -> void:
	if not bitmap.get_size(): return
	
	var polygon: PackedVector2Array = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, bitmap.get_size()), 0)[0]
	for i: int in polygon.size():
		polygon[i] = Vector2(Iso.from_grid(polygon[i]))
	
	from_polygon(polygon)


## Sets the highlighted area according to a [BitShape].
func from_bitshape(bitshape: BitShape) -> void:
	from_bitmap(bitshape)
	position = Iso.from_grid(bitshape.offset) - Vector2(16, 0)


## Sets the highlighted area according to a [BitPath].
func from_bitpath(bitpath: BitPath) -> void:
	bitpath.update()
	from_bitmap(bitpath)
	
	global_position = Iso.from_grid(bitpath.position - Vector2i(bitpath.spill, bitpath.spill)) - Vector2(16, 0)



# internal

func _ready() -> void:
	monitorable = false


var _time: float = 0
func _process(delta: float) -> void:
	_time += delta
	$Fill.texture_rotation = sin(_time / 240) * 180
