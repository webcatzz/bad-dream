class_name Character
extends Area2D

@export var data: CharacterData

var color: Color
var walk_speed: float = 96

@export var facing := Vector2i(0, 1)
var tile: Vector2i:
	set(value): position = Game.grid.tile_to_point(tile)
	get: return Game.grid.point_to_tile(position)

@onready var sprite: Sprite2D = $Sprite
@onready var nav: NavigationAgent2D = $Nav



# navigation

func walk_to(point: Vector2) -> void:
	nav.target_position = point


func stop_walking() -> void:
	nav.target_position = global_position


func _process(delta: float):
	if not nav.is_navigation_finished():
		global_position = global_position.move_toward(nav.get_next_path_position(), walk_speed * delta)



# data

func _ready() -> void:
	load_data(data)


func load_data(data: CharacterData) -> void:
	color = data.color
	sprite.texture = data.sprite
	sprite.offset = data.sprite_offset
