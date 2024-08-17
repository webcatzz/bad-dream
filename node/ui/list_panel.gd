extends BoxContainer


signal chosen(resource: Resource)

@export var title: String
@export var cancel_first: bool
@export_multiline var blurb: String

var items: Array[Resource]

@onready var _list: ItemList = $Panel/VBox/List
@onready var _info: InfoPanel = $Info


func clear() -> void:
	items.clear()
	_list.clear()


func add_item(resource: Resource) -> void:
	items.append(resource)
	_list.add_item(resource.name)


func focus_first() -> void:
	find_next_valid_focus().grab_focus()



# internal

func _ready() -> void:
	$Panel/VBox/Label.text = title
	if cancel_first: $Panel/VBox.move_child($Panel/VBox/Cancel, 1)


func _on_item_selected(idx: int) -> void:
	_info.set_title(items[idx].name)
	_info.add_label(items[idx].description, &"LabelMuted")


func _on_item_activated(idx: int) -> void:
	chosen.emit(items[idx])


func _on_cancel_pressed() -> void:
	chosen.emit(null)


func _on_list_focus_entered() -> void:
	_list.select(0)
	_on_item_selected(0)


func _on_cancel_focus_entered() -> void:
	_info.set_title("")
	_info.add_label(blurb, &"LabelMuted")
