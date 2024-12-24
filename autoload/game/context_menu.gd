extends ItemList


signal chosen(idx: int)


func open() -> void:
	position = get_global_mouse_position()
	show()


func close() -> void:
	hide()
	clear()


func add(text: String, callable: Callable, icon: Texture2D = null) -> void:
	var idx: int = add_item(text, icon)
	set_item_metadata(idx, callable)
	set_item_tooltip_enabled(idx, false)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("right_click"):
		close()


func _on_item_selected(idx: int) -> void:
	get_item_metadata(idx).call()
	close()
	accept_event()
