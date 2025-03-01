@icon("res://assets/editor/character.svg")
class_name Character
extends Area2D

signal clicked

const WALK_SPEED: float = 75 # Navigation speed.

@export var data: CharacterData
@export var facing := Vector2i(0, 1)

var coords: Vector2i:
	set(value): position = Grid.coords_to_point(coords)
	get: return Grid.point_to_coords(position)

var color: Color

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var trigger: Trigger = $Trigger
@onready var nav: NavigationAgent2D = $Nav



# navigation

# Starts navigating toward a point.
func walk_to(point: Vector2) -> void:
	nav.target_position = point


# Stops navigating.
func stop_walking() -> void:
	nav.target_position = global_position


# Navigates.
func _process(delta: float) -> void:
	if not nav.is_navigation_finished():
		global_position = global_position.move_toward(nav.get_next_path_position(), WALK_SPEED * delta)



# cursor

# Sets whether the character recieves mouse events.
func set_clickable(value: bool) -> void:
	trigger.input_pickable = value



# data

func _ready() -> void:
	load_data(data)
	trigger.walk_redirect = facing * 2


func load_data(data: CharacterData) -> void:
	color = data.color
	sprite.sprite_frames = data.sprite_frames
	sprite.offset = data.sprite_offset
