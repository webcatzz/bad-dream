class_name Player
extends Actor

const SPEED: float = 4

const CAMERA_ANGLE_SPEED: float = 2
const CAMERA_ZOOM_SPEED: float = 120
const MIN_CAMERA_ZOOM: float = 2
const MAX_CAMERA_ZOOM: float = 12

var _camera_angle_input: Vector2
var _camera_zoom_input: float
var _input_captors: PackedStringArray

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera



# input

func _unhandled_input(event: InputEvent) -> void:
	if _input_captors: return
	
	if Input.is_action_pressed("click"):
		var collision: Dictionary = Game.pick(event.position)
		if collision: walk_to(collision.position)
	
	if event is InputEventPanGesture:
		_camera_angle_input = event.delta * CAMERA_ANGLE_SPEED
	elif event is InputEventMagnifyGesture:
		_camera_zoom_input = (1.0 - event.factor) * CAMERA_ZOOM_SPEED


func capture_input(key: String) -> void:
	_input_captors.append(key)


func release_input(key: String) -> void:
	_input_captors.remove_at(_input_captors.find(key))



# camera

func set_camera_angle(value: Vector2) -> void:
	camera_pivot.rotation.y = value.x
	camera_pivot.rotation.x = clampf(value.y, -PI/2, PI/2)


func get_camera_angle() -> Vector2:
	return Vector2(camera_pivot.rotation.y, camera_pivot.rotation.x)


func set_camera_zoom(value: float) -> void:
	camera.position.z = clampf(value, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)


func get_camera_zoom() -> float:
	return camera.position.z


func _process(delta: float) -> void:
	super(delta)
	set_camera_angle(get_camera_angle() + _camera_angle_input * delta)
	set_camera_zoom(get_camera_zoom() + _camera_zoom_input * delta)
	_camera_zoom_input = move_toward(_camera_zoom_input, 0.0, 0.75)
