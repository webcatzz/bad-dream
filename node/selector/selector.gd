class_name Selector extends CharacterBody2D


enum Mode {
	DISABLED,
	MOVE,
	MENU,
}

@export var enabled: bool = false

var mode: Mode
var selected: Node2D

@onready var _collision: CollisionPolygon2D = $Collision
@onready var _area: Area2D = $Area
@onready var _sprite: Node2D = $Sprite
@onready var _camera: Camera2D = $Camera

@onready var _info: InfoPanel = $Info
@onready var _menu: TabContainer = $Menu


func set_enabled(value: bool) -> void:
	mode = Mode.MOVE if value else Mode.DISABLED
	
	visible = value
	_area.monitoring = value
	_collision.disabled = not value
	set_process_unhandled_key_input(value)
	if value: _camera.make_current()



# selection

func select(body: Node2D) -> void:
	selected = body
	match_position()
	
	mode = Mode.MENU
	_menu.open(selected.resource)
	
	_area.monitoring = false
	_sprite.position = Vector2.ZERO
	update_sprite()


func deselect() -> void:
	selected = null
	mode = Mode.MOVE
	_area.monitoring = true


func auto_select() -> void:
	var body: Node2D = get_body_below()
	if can_select(body): select(body)


func can_select(body: Node2D) -> bool:
	return body != null


func match_position(node: Node2D = selected) -> void:
	position = node.position



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if mode == Mode.MENU: return
	
	if event.is_action_pressed("ui_accept"):
		deselect() if selected else auto_select()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_released("ui_accept"):
		update_sprite()
		get_viewport().set_input_as_handled()
	
	else:
		velocity = 8 * Iso.from_grid(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
		if velocity: get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	if mode == Mode.MOVE:
		if velocity:
			move_and_slide()
		else:
			position = position.lerp(Iso.snap(position), 0.25)
		
		_sprite.position = Iso.snap(position) - position



# menu

func open_menu() -> void:
	if not selected: auto_select()
	mode = Mode.MENU
	_menu.open(selected.resource)



# area

func get_body_below() -> Node2D:
	return _area.get_overlapping_bodies()[0] if _area.monitoring and _area.has_overlapping_bodies() else null


func _on_body_entered(_body: Node2D) -> void:
	update_sprite()


func _on_body_exited(_body: Node2D) -> void:
	update_sprite()



# sprite

func update_sprite() -> void:
	if mode == Mode.MOVE:
		if can_select(get_body_below()):
			_sprite.expand(4)
			_sprite.modulate.a = 1
		else:
			_sprite.expand(0)
			_sprite.modulate.a = 0.125
	else:
		_sprite.expand(-6)



# internal

func _ready() -> void:
	_camera.enabled = true
	set_enabled(enabled)
