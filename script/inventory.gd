class_name Inventory extends Resource


var items: Array[Item]

var size: Vector2i
var grid: Array[Item]


func add_item(item: Item) -> void:
	items.append(item)


func remove_item(item: Item) -> void:
	items.erase(item)


func lift_item(item: Item) -> void:
	set_points(item, null)


func drop_item(item: Item, pos: Vector2i) -> void:
	item.position = pos
	set_points(item, item)


func can_item_fit(item: Item, pos: Vector2i) -> bool:
	for point: Vector2i in item.get_points():
		if get_item_at_pos(pos + point):
			return false
	return true



# helper

func pos_to_idx(pos: Vector2i) -> int:
	return pos.x + pos.y * size.x


func get_item_at_pos(pos: Vector2i) -> Item:
	return grid[pos_to_idx(pos)]


func set_points(item: Item, value: Item) -> void:
	for point: Vector2i in item.get_points():
		grid[pos_to_idx(item.position + point)] = value
