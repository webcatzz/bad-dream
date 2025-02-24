@tool
class_name Tile
extends Resource
## Single tile on a grid. Handles rendering and navigation.

@export var source_id: int
@export var tile_id: Vector2i
@export var coords: Vector2i

var canvas_item: RID = RenderingServer.canvas_item_create()


## Draws a tile to a grid.
func draw(grid: Grid, source_id: int, tile_id: Vector2i) -> void:
	self.source_id = source_id
	self.tile_id = tile_id
	var source: TileSetAtlasSource = grid.tile_set.get_source(source_id)
	var size: Vector2i = source.get_tile_size_in_atlas(tile_id) * source.texture_region_size
	var data: TileData = source.get_tile_data(tile_id, 0)
	# rendering
	RenderingServer.canvas_item_clear(canvas_item)
	RenderingServer.canvas_item_set_z_index(canvas_item, data.z_index)
	RenderingServer.canvas_item_add_texture_rect_region(
		canvas_item,
		Rect2(size * -0.5 - Vector2(data.texture_origin), size),
		source.texture.get_rid(),
		Rect2(tile_id * source.texture_region_size, size)
	)
	# navigation
	if grid.tile_set.get_navigation_layers_count():
		if data.get_navigation_polygon(0):
			grid.add_nav_polygon(data.get_navigation_polygon(0), Grid.coords_to_point(coords))


## Sets the tile's parent.
func set_parent(parent: CanvasItem) -> void:
	RenderingServer.canvas_item_set_parent(canvas_item, parent.get_canvas_item())


## Sets the tile's coords.
func set_coords(coords: Vector2i) -> void:
	self.coords = coords
	set_position(Grid.coords_to_point(coords))


## Sets the tile's position.
func set_position(position: Vector2) -> void:
	RenderingServer.canvas_item_set_transform(canvas_item, Transform2D(0, position))


## Stops the tile's functioning.
func kill() -> void:
	RenderingServer.free_rid(canvas_item)
