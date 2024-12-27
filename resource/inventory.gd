class_name Inventory
extends Resource

var items: Array[Item]


func add(item: Item) -> void:
	items.append(item)


func remove(item: Item) -> void:
	items.erase(item)


func has(item: Item) -> bool:
	return item in items


func count(item: Item) -> void:
	return items.count(item)


func find(name: String) -> Item:
	for item: Item in items:
		if item.name == name:
			return item
	return null
