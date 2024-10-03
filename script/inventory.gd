class_name Inventory extends Resource


var list: Array[Item]
var grid: Array[Array]
var size: Vector2i:
	set(value):
		size = value
		
		grid.resize(size.y)
		for row: Array in grid:
			row.resize(size.x)


func add_item(item: Item) -> void:
	list.append(item)


func remove_item(item: Item) -> void:
	list.erase(item)


func lift_item(item: Item) -> void:
	set_points(item, null)


func drop_item(item: Item, pos: Vector2i) -> void:
	item.position = pos
	set_points(item, item)


func can_item_fit(item: Item, pos: Vector2i) -> bool:
	for point: Vector2i in item.get_points():
		if at(pos + point):
			return false
	return true



# helper

func at(pos: Vector2i) -> Item:
	return grid[pos.x][pos.y]


func set_points(item: Item, value: Item) -> void:
	for point: Vector2i in item.get_points():
		point += item.position
		grid[point.x][point.y] = value
