class_name LoopingItemList extends ItemList


func _unhandled_key_input(event: InputEvent) -> void:
	if is_anything_selected():
		var selected: int = get_selected_items()[0]
		
		if event.is_action_pressed("ui_up"):
			if selected == 0:
				select(item_count - 1)
				item_selected.emit(item_count - 1)
				ensure_current_is_visible()
		
		elif event.is_action_pressed("ui_down"):
			if selected == item_count - 1:
				select(0)
				item_selected.emit(0)
				ensure_current_is_visible()
