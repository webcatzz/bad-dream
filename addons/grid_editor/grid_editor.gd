@tool
extends VBoxContainer

signal canvas_redraw_requested

enum Tool {
	SELECT,
	DRAW,
	FILL,
	REPLACE,
}

var grid: Grid

var tool: Tool = Tool.DRAW
var tool_erase: bool
var source_id: int
var tile_ids: Array[Vector2i]

var history: EditorUndoRedoManager
var staged_coords: Array[Vector2i]
var selected_coords: Array[Vector2i]

var mouse_held: bool
var mouse_rect: Rect2i

@onready var tool_list: ItemList = $Toolbar/ToolList
@onready var source_list: ItemList = $Main/SourceList
@onready var tile_list: ItemList = $Main/TileList



# input

func handle_input(event: InputEventMouse) -> void:
	if event is InputEventMouseButton:
		mouse_held = event.pressed
		if mouse_held:
			tool_erase = event.button_mask == MOUSE_BUTTON_MASK_RIGHT
			mouse_rect.position = _mouse_coords()
			mouse_rect.size = Vector2i.ZERO
		else:
			mouse_rect.end = _mouse_coords()
	elif mouse_held:
		mouse_rect.end = _mouse_coords()
	
	match tool:
		Tool.SELECT: _tool_select(event)
		Tool.DRAW: _tool_draw(event)
		Tool.FILL: _tool_fill(event)
		Tool.REPLACE: _tool_replace(event)


func _mouse_coords() -> Vector2i:
	return Grid.point_to_coords(grid.get_local_mouse_position())



# tools

func _tool_select(event: InputEventMouse) -> void:
	if mouse_held:
		if event is InputEventMouseButton and not event.shift_pressed and mouse_rect.position in staged_coords:
			selected_coords = staged_coords.duplicate()
		if selected_coords:
			staged_coords.clear()
			var displacement: Vector2i = mouse_rect.end - mouse_rect.position
			for coords: Vector2i in selected_coords:
				stage(coords + displacement)
		else:
			if not event.shift_pressed: staged_coords.clear()
			var rect: Rect2i = mouse_rect.abs()
			for x: int in rect.size.x + 1:
				for y: int in rect.size.y + 1:
					var coords: Vector2i = rect.position + Vector2i(x, y)
					if grid.has_tile(coords): stage(coords)
	
	elif selected_coords:
		commit_move(mouse_rect.end - mouse_rect.position)


func _tool_draw(event: InputEventMouse) -> void:
	if mouse_held:
		if event.shift_pressed: # line
			staged_coords.clear()
			var min_axis: int = mouse_rect.size.abs().min_axis_index()
			mouse_rect.end[min_axis] = mouse_rect.position[min_axis]
			stage_rect(mouse_rect.abs())
		elif event.ctrl_pressed: # rect
			staged_coords.clear()
			stage_rect(mouse_rect.abs())
		else:
			stage(mouse_rect.end)
	
	elif event is InputEventMouseButton:
		commit_paint()


func _tool_fill(event: InputEventMouse) -> void:
	if event is InputEventMouseButton and mouse_held:
		var target: Tile = grid.get_tile(mouse_rect.position)
		if target:
			target = target.duplicate()
			pass


func _tool_replace(event: InputEventMouse) -> void:
	if event is InputEventMouseButton and mouse_held:
		var target: Tile = grid.get_tile(mouse_rect.position)
		if target:
			for cell: Tile in grid.cells:
				if cell.source_id == target.source_id and cell.tile_id == target.tile_id:
					stage(cell.coords)
			commit_paint()



# history

func stage(coords: Vector2i) -> void:
	var idx: int = staged_coords.bsearch(coords)
	if idx < staged_coords.size() and staged_coords[idx] != coords or idx == staged_coords.size():
		staged_coords.insert(idx, coords)
		canvas_redraw_requested.emit()


func stage_rect(rect: Rect2i) -> void:
	for x: int in range(rect.position.x, rect.end.x + 1):
		for y: int in range(rect.position.y, rect.end.y + 1):
			stage(Vector2i(x, y))


func clear_staged() -> void:
	staged_coords.clear()
	canvas_redraw_requested.emit()


func commit_paint() -> void:
	history.create_action("Paint tiles")
	
	for coords: Vector2i in staged_coords:
		if grid.has_tile(coords):
			var tile: Tile = grid.get_tile(coords)
			history.add_undo_method(grid, "set_tile", coords, tile.source_id, tile.tile_id)
		else:
			history.add_undo_method(grid, "remove_tile", coords)
		if tool_erase:
			history.add_do_method(grid, "remove_tile", coords)
		else:
			history.add_do_method(grid, "set_tile", coords, source_id, tile_ids.pick_random())
	
	history.commit_action()
	clear_staged()


func commit_move(displacement: Vector2i) -> void:
	history.create_action("Move tiles")
	
	for coords: Vector2i in selected_coords:
		if grid.has_tile(coords):
			var tile: Tile = grid.get_tile(coords)
			var new_coords: Vector2i = coords + displacement
			
			if grid.has_tile(new_coords):
				var old_tile: Tile = grid.get_tile(new_coords)
				history.add_undo_method(grid, "set_tile", new_coords, old_tile.source_id, old_tile.tile_id)
			else:
				history.add_undo_method(grid, "remove_tile", new_coords)
			history.add_undo_method(grid, "set_tile", coords, tile.source_id, tile.tile_id)
			
			history.add_do_method(grid, "remove_tile", coords)
			history.add_do_method(grid, "set_tile", new_coords, tile.source_id, tile.tile_id)
	
	history.commit_action()
	selected_coords.clear()



# drawing

func handle_draw(overlay: Control) -> void:
	var canvas_scale: float = grid.get_viewport_transform().get_scale().x
	var canvas_offset: Vector2 = overlay.get_local_mouse_position() - grid.get_local_mouse_position() * canvas_scale
	
	for coords: Vector2i in staged_coords:
		var point: Vector2 = Grid.coords_to_point(coords) * canvas_scale + canvas_offset
		var half_x: Vector2 = Grid.RIGHT / 2 * canvas_scale
		var half_y: Vector2 = Grid.DOWN / 2 * canvas_scale
		overlay.draw_colored_polygon([
			point - half_x - half_y,
			point + half_x - half_y,
			point + half_x + half_y,
			point - half_x + half_y,
		], Color(Color.WHITE, 0.125))



# lists

func _populate_sources() -> void:
	for i: int in grid.tile_set.get_source_count():
		var source: TileSetAtlasSource = grid.tile_set.get_source(grid.tile_set.get_source_id(i))
		source_list.add_item(source.texture.resource_path.get_file(), source.texture)
	source_list.select(0)
	_on_source_selected(0)


func _populate_tiles() -> void:
	var source: TileSetAtlasSource = grid.tile_set.get_source(source_id)
	tile_list.clear()
	
	for i: int in source.get_tiles_count():
		var tile_id: Vector2i = source.get_tile_id(i)
		var id: int = tile_list.add_icon_item(_get_tile_texture(source, tile_id))
		tile_list.set_item_tooltip(id, str(tile_id))
	tile_list.select(0)
	_on_tile_selection_changed(0, true)


func _on_tool_selected(idx: int) -> void:
	tool = idx
	clear_staged()


func _on_source_selected(idx: int) -> void:
	source_id = grid.tile_set.get_source_id(idx)
	_populate_tiles()


func _on_tile_selection_changed(_idx: int, _selected: bool) -> void:
	tile_ids.clear()
	for idx: int in tile_list.get_selected_items():
		tile_ids.append(grid.tile_set.get_source(grid.tile_set.get_source_id(source_id)).get_tile_id(idx))


func _get_tile_texture(source: TileSetAtlasSource, tile_id: Vector2i) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = source.texture
	texture.region = Rect2(tile_id * source.texture_region_size, source.get_tile_size_in_atlas(tile_id) * source.texture_region_size)
	return texture



# opening & closing

func _ready() -> void:
	tool_list.select(tool)


func _on_visibility_changed() -> void:
	if visible:
		if grid and grid.tile_set:
			_populate_sources()
	else:
		source_list.clear()
		tile_list.clear()
