class_name Character
extends CharacterBody3D

signal clicked

const WALK_SPEED: float = 4 ## Navigation speed.

@export var data := CharacterData.new()

var color: Color

@onready var nav: NavigationAgent3D = $Nav



# navigation

## Starts navigating toward a point.
func walk_to(point: Vector3) -> void:
	nav.target_position = point


## Stops navigating.
func stop_walking() -> void:
	nav.target_position = global_position


func _process(delta: float) -> void:
	if nav and not nav.is_navigation_finished():
		global_position = global_position.move_toward(nav.get_next_path_position(), WALK_SPEED * delta)



# cursor events

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print(name)


func _mouse_enter() -> void:
	pass


func _mouse_exit() -> void:
	pass



# data

func _ready() -> void:
	if data: load_data(data)


## Loads properties from a data resource.
func load_data(data: CharacterData) -> void:
	color = data.color



# movement

func _physics_process(delta: float) -> void:
	velocity = get_gravity()
	move_and_slide()
