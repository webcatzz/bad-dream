extends BoxContainer


signal chosen(resource: Resource)

@export var title: String

var items: Array[Resource]

@onready var _list: ItemList = $Panel/VBox/List
@onready var _info: InfoPanel = $Info


func clear() -> void:
	items.clear()
	_list.clear()


func add_item(resource: Resource) -> void:
	items.append(resource)
	_list.add_item(resource.name)


func focus_list() -> void:
	_list.grab_focus()
	_list.select(0)
	_on_item_selected(0)



# internal

func _on_item_selected(idx: int) -> void:
	_info.set_title(items[idx].name)
	_info.add_label(items[idx].description, &"LabelMuted")


func _on_item_activated(idx: int) -> void:
	chosen.emit(items[idx])


func _ready() -> void:
	$Panel/VBox/Label.text = title


func _on_cancel_pressed() -> void:
	chosen.emit(null)
