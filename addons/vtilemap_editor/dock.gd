@tool
extends VBoxContainer

var editor: VTileMapEditor


func read(editor: VTileMapEditor) -> void:
	self.editor = editor
	
	$Toolbar/Tool.select(editor.tool)
	
	if editor.map.tile_set:
		for i: int in editor.map.tile_set.get_source_count():
			var source: TileSetAtlasSource = editor.map.tile_set.get_source(editor.map.tile_set.get_source_id(i))
			$Main/SourceList.add_item(source.texture.resource_path.get_file(), source.texture)
		$Main/SourceList.select(0)
		_on_source_selected(0)


func _on_tool_selected(idx: int) -> void:
	editor.tool = idx


func _on_source_selected(idx: int) -> void:
	editor.source_id = editor.map.tile_set.get_source_id(idx)
	
	$Main/TileList.clear()
	var source: TileSetAtlasSource = editor.map.tile_set.get_source(editor.source_id)
	for i: int in source.get_tiles_count():
		var texture := AtlasTexture.new()
		texture.atlas = source.texture
		texture.region = Rect2(source.get_tile_id(i) * source.texture_region_size, source.texture_region_size)
		$Main/TileList.add_icon_item(texture)
	$Main/TileList.select(0)
	_on_tile_selection_changed(0, true)


func _on_tile_selection_changed(_idx: int, _selected: bool) -> void:
	editor.tile_ids.clear()
	for idx: int in $Main/TileList.get_selected_items():
		editor.tile_ids.append(editor.map.tile_set.get_source(editor.map.tile_set.get_source_id(editor.source_id)).get_tile_id(idx))
