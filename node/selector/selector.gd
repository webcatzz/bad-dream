class_name Selector extends CharacterBody2D


enum Mode {
	DISABLED,
	FREE,
	MOVE,
	ACT,
}

@export var enabled: bool = false

var mode: Mode
var selected: Node2D

@onready var _collision: CollisionPolygon2D = $Collision
@onready var _area: Area2D = $Area
@onready var _sprite: Sprite2D = $Sprite
@onready var _camera: Camera2D = $Camera


func set_enabled(value: bool) -> void:
	mode = Mode.FREE if value else Mode.DISABLED
	
	visible = value
	_area.monitoring = value
	_collision.disabled = not value
	set_process_unhandled_key_input(value)
	if value: _camera.make_current()


func select(body: Node2D) -> void:
	selected = body
	mode = Mode.MOVE
	match_position()
	
	_area.monitoring = false
	_sprite.position = Vector2.ZERO


func deselect() -> void:
	selected = null
	mode = Mode.FREE
	
	_area.monitoring = true


func match_position(node: Node2D = selected) -> void:
	position = node.position



# internal

func _ready() -> void:
	_camera.enabled = true
	set_enabled(enabled)



# input

func _unhandled_key_input(_event: InputEvent) -> void:
	match mode:
		Mode.FREE:
			if Input.is_action_pressed("interact"):
				if _area.has_overlapping_bodies():
					select(_area.get_overlapping_bodies()[0])
					get_viewport().set_input_as_handled()
			else:
				velocity = 8 * Iso.from_grid(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
				if velocity: get_viewport().set_input_as_handled()
		
		Mode.MOVE:
			if Input.is_action_pressed("interact"):
				deselect()
				get_viewport().set_input_as_handled()
			else:
				var input: Vector2i
				if Input.is_action_pressed("move_up"): input = Vector2i.UP
				elif Input.is_action_pressed("move_down"): input = Vector2i.DOWN
				elif Input.is_action_pressed("move_left"): input = Vector2i.LEFT
				elif Input.is_action_pressed("move_right"): input = Vector2i.RIGHT
				else: return
				move(input)
				get_viewport().set_input_as_handled()


func move(motion: Vector2i) -> void:
	selected.position += Iso.from_grid(motion)


func _physics_process(_delta: float) -> void:
	if mode == Mode.FREE:
		if velocity:
			move_and_slide()
		else:
			position = position.lerp(Iso.snap(position), 0.25)
		
		_sprite.position = Iso.snap(position) - position



# area

func _on_body_entered(body: Node2D) -> void:
	pass


func _on_body_exited(body: Node2D) -> void:
	pass
