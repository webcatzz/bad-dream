@tool
extends VBoxContainer

signal canvas_redraw_requested

enum Tool {
	SELECT,
	DRAW,
	LINE,
	RECT,
	FILL,
	REPLACE,
}

var map: VTileMap

var tool: Tool = Tool.DRAW
var tool_mode: bool
var source_id: int
var tile_ids: Array[Vector2i]

var history: EditorUndoRedoManager
var staged: Array[Vector2i]

var mouse_held: bool
var mouse_rect: Rect2i



# input

func handle_input(event: InputEventMouse) -> void:
	if event is InputEventMouseButton:
		mouse_held = event.pressed
		if mouse_held:
			tool_mode = event.button_mask != MOUSE_BUTTON_MASK_RIGHT
			mouse_rect.position = _mouse_coords()
			mouse_rect.size = Vector2i.ZERO
		else:
			mouse_rect.end = _mouse_coords()
	elif mouse_held:
		mouse_rect.end = _mouse_coords()
	
	match tool:
		Tool.SELECT: _tool_select(event)
		Tool.DRAW: _tool_draw(event)
		Tool.LINE: _tool_line(event)
		Tool.RECT: _tool_rect(event)
		Tool.FILL: _tool_fill(event)
		Tool.REPLACE: _tool_replace(event)


func _mouse_coords() -> Vector2i:
	return map.local_to_map(map.get_local_mouse_position())



# tools

func _tool_select(event: InputEventMouse) -> void:
	if event is InputEventMouse:
		if staged[staged.bsearch(mouse_rect.end)] == mouse_rect.end:
			pass
		
		else:
			if event.shift_pressed:
				stage(mouse_rect.end)
			
			elif not mouse_held:
				if mouse_rect.size:
					var i: int
					while i < staged.size():
						if map.get_cell(staged[i]):
							i += 1
						else:
							staged.remove_at(i)
					canvas_redraw_requested.emit()
				else:
					staged.clear()
					canvas_redraw_requested.emit()
	
	if mouse_held:
		staged.clear()
		stage_rect(mouse_rect.abs())


func _tool_draw(event: InputEventMouse) -> void:
	if mouse_held:
		stage(mouse_rect.end)
	
	elif event is InputEventMouseButton:
		commit()


func _tool_line(event: InputEventMouse) -> void:
	if mouse_held:
		staged.clear()
		var min_axis: int = mouse_rect.size.abs().min_axis_index()
		mouse_rect.end[min_axis] = mouse_rect.position[min_axis]
		stage_rect(mouse_rect.abs())
	
	elif event is InputEventMouseButton:
		commit()


func _tool_rect(event: InputEventMouse) -> void:
	if mouse_held:
		staged.clear()
		stage_rect(mouse_rect.abs())
	
	elif event is InputEventMouseButton:
		commit()


func _tool_fill(event: InputEventMouse) -> void:
	if event is InputEventMouseButton and mouse_held:
		var target: VTileMapCell = map.get_cell(mouse_rect.position)
		if target:
			target = target.duplicate()
			pass


func _tool_replace(event: InputEventMouse) -> void:
	if event is InputEventMouseButton and mouse_held:
		var target: VTileMapCell = map.get_cell(mouse_rect.position)
		if target:
			for cell: VTileMapCell in map.cells:
				if cell.source_id == target.source_id and cell.tile_id == target.tile_id:
					stage(cell.coords)
			commit()



# history

func stage(coords: Vector2i) -> void:
	var idx: int = staged.bsearch(coords)
	if idx < staged.size() and staged[idx] != coords or idx == staged.size():
		staged.insert(idx, coords)
		canvas_redraw_requested.emit()


func stage_rect(rect: Rect2i) -> void:
	for x: int in range(rect.position.x, rect.end.x + 1):
		for y: int in range(rect.position.y, rect.end.y + 1):
			stage(Vector2i(x, y))


func commit() -> void:
	history.create_action("Paint tiles")
	
	for coords: Vector2i in staged:
		var cell: VTileMapCell = map.get_cell(coords)
		if cell:
			history.add_undo_method(map, "set_cell", coords, cell.source_id, cell.tile_id)
		else:
			history.add_undo_method(map, "clear_cell", coords)
		if tool_mode:
			history.add_do_method(map, "set_cell", coords, source_id, tile_ids.pick_random())
		else:
			history.add_do_method(map, "clear_cell", coords)
	
	history.commit_action()
	
	staged.clear()
	canvas_redraw_requested.emit()



# drawing

func handle_draw(overlay: Control) -> void:
	var canvas_scale: float = map.get_viewport_transform().get_scale().x
	var canvas_offset: Vector2 = overlay.get_local_mouse_position() - map.get_local_mouse_position() * canvas_scale
	
	for coords: Vector2i in staged:
		var point: Vector2 = map.map_to_local(coords) * canvas_scale + canvas_offset
		var half_x: Vector2 = Vector2(map.x_axis) * 0.5 * canvas_scale
		var half_y: Vector2 = Vector2(map.y_axis) * 0.5 * canvas_scale
		overlay.draw_colored_polygon([
			point - half_x - half_y,
			point + half_x - half_y,
			point + half_x + half_y,
			point - half_x + half_y,
		], Color(Color.WHITE, 0.125))



# lists

func _on_tool_selected(idx: int) -> void:
	tool = idx


func _on_source_selected(idx: int) -> void:
	source_id = map.tile_set.get_source_id(idx)
	var source: TileSetAtlasSource = map.tile_set.get_source(source_id)
	
	$Main/TileList.clear()
	for i: int in source.get_tiles_count():
		$Main/TileList.add_icon_item(_get_tile_texture(source, source.get_tile_id(i)))
	$Main/TileList.select(0)
	_on_tile_selection_changed(0, true)


func _on_tile_selection_changed(_idx: int, _selected: bool) -> void:
	tile_ids.clear()
	for idx: int in $Main/TileList.get_selected_items():
		tile_ids.append(map.tile_set.get_source(map.tile_set.get_source_id(source_id)).get_tile_id(idx))


func _get_tile_texture(source: TileSetAtlasSource, tile_id: Vector2i) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = source.texture
	texture.region = Rect2(tile_id * source.texture_region_size, source.texture_region_size)
	return texture



# opening & closing

func _ready() -> void:
	$Toolbar/Tool.select(tool)


func _on_visibility_changed() -> void:
	if visible:
		if map.tile_set:
			for i: int in map.tile_set.get_source_count():
				var source: TileSetAtlasSource = map.tile_set.get_source(map.tile_set.get_source_id(i))
				$Main/SourceList.add_item(source.texture.resource_path.get_file(), _get_tile_texture(source, source.get_tile_id(0)))
			$Main/SourceList.select(0)
			_on_source_selected(0)
	else:
		$Main/SourceList.clear()
		$Main/TileList.clear()
