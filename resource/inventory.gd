class_name Inventory
extends Resource

var items: Array[Item]


func add(item: Item, count: int = 1) -> void:
	for i: int in count:
		items.append(item)
	
	print("inventory: ", items)


func remove(item: Item, count: int = 1) -> void:
	for i: int in count:
		items.erase(item)


func has(item: Item) -> bool:
	return item in items


func count(item: Item) -> void:
	return items.count(item)
