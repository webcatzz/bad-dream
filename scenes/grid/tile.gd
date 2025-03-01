@tool
class_name Tile
extends Resource
## Single tile on a grid. Handles rendering and navigation.

@export var coords: Vector2i : set = set_coords
@export var source_id: int
@export var tile_id: Vector2i

var canvas_item: RID = RenderingServer.canvas_item_create()


## Draws the tile on a grid.
func draw(grid: Grid) -> void:
	var source: TileSetAtlasSource = grid.tile_set.get_source(source_id)
	var size: Vector2i = source.get_tile_size_in_atlas(tile_id) * source.texture_region_size
	var data: TileData = source.get_tile_data(tile_id, 0)
	# rendering
	RenderingServer.canvas_item_set_parent(canvas_item, grid.get_canvas_item())
	RenderingServer.canvas_item_set_z_index(canvas_item, data.z_index)
	RenderingServer.canvas_item_clear(canvas_item)
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


## Renders the tile at some coords.
func set_coords(value: Vector2i) -> void:
	coords = value
	RenderingServer.canvas_item_set_transform(canvas_item, Transform2D(0, Grid.coords_to_point(coords)))


## Stops the tile's functioning.
func kill() -> void:
	RenderingServer.free_rid(canvas_item)
