class_name TileHighlight extends Area2D
## Bare-bones tile highlighter.


var polygon: PackedVector2Array


static func node() -> Area2D:
	return preload("res://node/tile_highlight.tscn").instantiate()


func _ready() -> void:
	self.monitorable = false
	$Fill.polygon = polygon
	$Collision.polygon = polygon


var _time: float = 0
func _process(delta: float) -> void:
	_time += delta
	$Fill.texture_rotation = sin(_time / 240) * 180


## Sets the highlighted area according to a [Rect2i].
func from_rect(rect: Rect2i) -> void:
	rect.position = Iso.from_cart(rect.position)
	rect.end = Iso.from_cart(rect.end)
	polygon = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]


## Sets the highlighted area according to a [BitMap].
func from_bitmap(bitmap: BitMap) -> void:
	polygon = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, bitmap.get_size()))[0]
	
	for i: int in polygon.size():
		polygon[i] = Vector2(Iso.from_cart(polygon[i]))


## Sets the highlighted area according to a [BitShape].
func from_bitshape(bitshape: BitShape) -> void:
	from_bitmap(bitshape)
	position = Iso.from_cart(bitshape.offset) - Vector2i(16, 0)


## Sets the highlighted area according to a [PackedVector2Array] of points.
func from_polygon(polygon: PackedVector2Array) -> void:
	self.polygon = polygon
