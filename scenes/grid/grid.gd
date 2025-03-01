@tool
@icon("res://assets/editor/grid.svg")
class_name Grid
extends Node2D
## Manages tiles.

const UP := Vector2(-14, -7)
const DOWN := Vector2(14, 7)
const LEFT := Vector2(-10, 10)
const RIGHT := Vector2(10, -10)

@export var tile_set: TileSet
@export_storage var _tiles: Array

var _astar := AStarGrid2D.new()



# coords

## Converts grid coordinates to local coordinates.
static func coords_to_point(coords: Vector2i) -> Vector2:
	return coords.x * RIGHT + coords.y * DOWN


## Converts local coordinates to grid coordinates.
static func point_to_coords(point: Vector2) -> Vector2i:
	var coords: Vector2
	coords.x = (DOWN.x * point.y - DOWN.y * point.x) / (DOWN.x * RIGHT.y - DOWN.y * RIGHT.x)
	coords.y = (point.x - coords.x * RIGHT.x) / DOWN.x
	return coords.round()


## Snaps a position to the grid.
static func snap(point: Vector2) -> Vector2:
	return coords_to_point(point_to_coords(point))



# tiles

## Sets the tile at some coords.
func set_tile(coords: Vector2i, source_id: int, tile_id: Vector2i) -> void:
	if has_tile(coords): remove_tile(coords)
	
	var tile := Tile.new()
	tile.coords = coords
	tile.source_id = source_id
	tile.tile_id = tile_id
	tile.draw(self)
	
	_list_add_tile(tile)


## Removes the tile at some coords.
func remove_tile(coords: Vector2i) -> void:
	if not has_tile(coords): return
	
	get_tile(coords).kill()
	
	_list_remove_tile(coords)


## Returns the tile at some coords.
func get_tile(coords: Vector2i) -> Tile:
	return _list_get_tile(coords)


## Returns true if there is a tile at some coords.
func has_tile(coords: Vector2i) -> bool:
	return _list_has_tile(coords)



# tile list

# Inserts a tile in the list. Keeps the list sorted.
func _list_add_tile(tile: Tile) -> void:
	_tiles.insert(_list_idx(tile.coords), tile)


# Removes a tile from the list.
func _list_remove_tile(coords: Vector2i) -> void:
	_tiles.remove_at(_list_idx(coords))


# Returns a tile with some coords in the list.
func _list_get_tile(coords: Vector2i) -> Tile:
	return _tiles[_list_idx(coords)] if _list_has_tile(coords) else null


# Returns true if the list has a tile with some coords.
func _list_has_tile(coords: Vector2i) -> bool:
	var idx: int = _list_idx(coords)
	return idx < _tiles.size() and _tiles[idx].coords == coords


# Returns the index of some coords in the list.
func _list_idx(coords: Vector2i) -> int:
	return _tiles.map(func(tile: Tile) -> Vector2i: return tile.coords).bsearch_custom(coords, _sort_coords, true)


# The list's sorting function.
func _sort_coords(a: Vector2i, b: Vector2i) -> bool:
	return a.y < b.y or a.y == b.y and a.x > b.x



# physics

func at(point: Vector2) -> Area2D:
	var params := PhysicsPointQueryParameters2D.new()
	params.collide_with_bodies = false
	params.collide_with_areas = true
	params.collision_mask = 0b1
	params.position = point
	var collisions: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(params, 1)
	return collisions.front().collider if collisions else null


func ray(from: Vector2, to: Vector2) -> bool:
	var params := PhysicsRayQueryParameters2D.create(from, to)
	return true if get_world_2d().direct_space_state.intersect_ray(params) else false



# navigation

func add_nav_polygon(nav_poly: NavigationPolygon, point: Vector2) -> void:
	if Engine.is_editor_hint(): return
	var nav_region := NavigationRegion2D.new()
	nav_region.navigation_polygon = nav_poly
	nav_region.position = point
	add_child(nav_region)



# astar

func set_coords_open(coords: Vector2i, open: bool) -> void:
	_astar.set_point_solid(coords, not open)


func are_coords_open(coords: Vector2i) -> bool:
	return _astar.is_in_boundsv(coords) and not _astar.is_point_solid(coords)


func _read_coords_open() -> void:
	for x: int in _astar.region.size.x:
		for y: int in _astar.region.size.y:
			var coords: Vector2i = Vector2i(x, y) + _astar.region.position
			set_coords_open(coords, has_tile(coords))



# virtual

func _ready() -> void:
	for tile: Tile in _tiles:
		tile.draw(self)
		_astar.region = _astar.region.expand(tile.coords)
	
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.region.size += Vector2i.ONE
	_astar.update()
	_read_coords_open()
