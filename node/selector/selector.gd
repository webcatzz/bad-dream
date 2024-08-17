class_name Selector extends CharacterBody2D


signal mode_changed(mode: Mode)

enum Mode {
	DISABLED,
	FREE,
	MOVE,
	ACT, # used in actor selector
}

@export var enabled: bool = false

var mode: Mode:
	set(value):
		mode = value
		mode_changed.emit(mode)
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
	_set_sprite_squeezed(true)


func deselect() -> void:
	selected = null
	mode = Mode.FREE
	
	_area.monitoring = true
	_set_sprite_squeezed(false)


func auto_select() -> void:
	var body: Node2D = get_body_below()
	if can_select(body): select(body)


func can_select(body: Node2D) -> bool:
	return body != null


func match_position(node: Node2D = selected) -> void:
	position = node.position



# input

func _unhandled_key_input(_event: InputEvent) -> void:
	match mode:
		Mode.FREE:
			if Input.is_action_just_pressed("interact"):
				auto_select()
				get_viewport().set_input_as_handled()
			else:
				velocity = 8 * Iso.from_grid(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
				if velocity: get_viewport().set_input_as_handled()
		
		Mode.MOVE:
			if Input.is_action_just_pressed("interact"):
				deselect()
				get_viewport().set_input_as_handled()
			else:
				var input: Vector2i
				if Input.is_action_just_pressed("move_up"): input = Vector2i.UP
				elif Input.is_action_just_pressed("move_down"): input = Vector2i.DOWN
				elif Input.is_action_just_pressed("move_left"): input = Vector2i.LEFT
				elif Input.is_action_just_pressed("move_right"): input = Vector2i.RIGHT
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


func get_body_below() -> Node2D:
	return _area.get_overlapping_bodies()[0] if _area.monitoring and _area.has_overlapping_bodies() else null



# sprite

func _set_sprite_squeezed(value: bool) -> void:
	_sprite.region_rect.position.x = 34 if value else 0



# internal

func _ready() -> void:
	_camera.enabled = true
	set_enabled(enabled)
