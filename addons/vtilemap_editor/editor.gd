@tool
class_name VTileMapEditor
extends EditorPlugin

enum Tool {
	SELECTION,
	PAINT,
	BUCKET,
}

var map: VTileMap
var dock: Control

var tool: Tool = Tool.PAINT
var source_id: int
var tile_ids: Array[Vector2i]

var selected: Array[VTileMapCell]

var mouse_held: bool
var mouse_rect: Rect2i



# handling

func _handles(object: Object) -> bool:
	return object is VTileMap


func _edit(object: Object) -> void:
	map = object
	_remove_dock()
	if map: _add_dock()



# input

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if dock and dock.visible and event is InputEventMouse:
		
		if event is InputEventMouseButton:
			mouse_held = event.pressed
			if mouse_held:
				mouse_rect.position = _get_mouse_coords()
				mouse_rect.size = Vector2i.ZERO
		elif mouse_held:
			mouse_rect.end = _get_mouse_coords()
		
		match tool:
			Tool.SELECTION:
				pass
			
			Tool.PAINT:
				if mouse_held:
					var coords: Vector2i = _get_mouse_coords()
					
					if event.shift_pressed:
						if event.meta_pressed:
							var abs_rect: Rect2i = mouse_rect.abs()
							for x: int in abs_rect.size.x + 1:
								for y: int in abs_rect.size.y + 1:
									_input_cell(abs_rect.position + Vector2i(x, y), event)
						else:
							var min_axis: int = (coords - mouse_rect.position).abs().min_axis_index()
							coords[min_axis] = mouse_rect.position[min_axis]
					
					_input_cell(coords, event)
			
			Tool.BUCKET:
				if event is InputEventMouseButton and mouse_held:
					var target: VTileMapCell = map.get_cell(_get_mouse_coords())
					if target:
						target = target.duplicate()
						match event.button_mask:
							MOUSE_BUTTON_MASK_LEFT:
								for i: int in map.cells.size():
									if map.cells[i].source_id == target.source_id and map.cells[i].tile_id == target.tile_id:
										map.cells[i].source_id = source_id
										map.cells[i].tile_id = tile_ids.pick_random()
								map.queue_redraw()
							MOUSE_BUTTON_MASK_RIGHT:
								var i: int = 0
								while i < map.cells.size():
									if map.cells[i].source_id == target.source_id and map.cells[i].tile_id == target.tile_id:
										map.clear_cell(map.cells[i].coords)
									else:
										i += 1
		
		return true
	return false


func _get_mouse_coords() -> Vector2i:
	return map.local_to_map(map.get_local_mouse_position())


func _input_cell(coords: Vector2i, event: InputEventMouse) -> void:
	match event.button_mask:
		MOUSE_BUTTON_MASK_LEFT:
			map.set_cell(coords, source_id, tile_ids.pick_random())
		MOUSE_BUTTON_MASK_RIGHT:
			map.clear_cell(coords)



# drawing

func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if mouse_rect:
		pass



# dock

func _add_dock() -> void:
	dock = preload("res://addons/vtilemap_editor/dock.tscn").instantiate()
	dock.read(self)
	add_control_to_bottom_panel(dock, "VTileMap")


func _remove_dock() -> void:
	if dock:
		remove_control_from_bottom_panel(dock)
		dock.queue_free()
		dock = null
