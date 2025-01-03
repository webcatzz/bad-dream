class_name Inventory
extends Resource

var items: Array[Item]
var grid: Array[Array]


func place(item: Item, coords: Vector2i) -> bool:
	if can_place(item, coords):
		items.append(item)
		_fill_shape(item.shape, coords, item)
		return true
	return false


func remove(item: Item) -> void:
	_fill_shape(item.shape, get_coords(item), null)
	items.erase(item)


func at(x: int, y: int) -> Item:
	return grid[y][x]


func atv(coords: Vector2i) -> Item:
	return at(coords.x, coords.y)


func can_place(item: Item, coords: Vector2i) -> bool:
	if coords.x + item.shape.get_size().x > width(): return false
	if coords.y + item.shape.get_size().y > height(): return false
	
	for y: int in item.shape.get_size().y:
		for x: int in item.shape.get_size().x:
			if item.shape.get_bit(x, y) and at(coords.x + x, coords.y + y):
				return false
	
	return true


func get_coords(item: Item) -> Vector2i:
	var x_offset: int = 0
	while not item.shape.get_bit(x_offset, 0):
		x_offset += 1
	
	for y: int in height():
		for x: int in width():
			if at(x, y) == item:
				return Vector2i(x - x_offset, y)
	return -Vector2i.ONE



# size

func width() -> int:
	return grid.front().size()


func height() -> int:
	return grid.size()


func size() -> Vector2i:
	return Vector2i(width(), height())


func set_size(x: int, y: int) -> void:
	grid.resize(y)
	for row: Array[Item] in grid:
		row.resize(x)
		row.fill(null)



# helper

func _fill_shape(shape: BitMap, coords: Vector2i, value: Item) -> void:
	for y: int in shape.get_size().y:
		for x: int in shape.get_size().x:
			if shape.get_bit(x, y):
				grid[coords.y + y][coords.x + x] = value
