extends CharacterBody2D


signal body_entered(body: Node2D)
signal emptied
signal squeezed
signal released
signal tile_changed

@export var controllable: bool = true:
	set(value):
		controllable = value
		$Camera.enabled = controllable
		if controllable: $Camera.make_current()

var tile: Vector2i
var body: Node2D
var is_squeezed: bool = false


func get_body() -> Node2D:
	return $Area.get_overlapping_bodies()[0] if $Area.get_overlapping_bodies() else null


func squeeze() -> void:
	body = get_body()
	if not body: return
	
	is_squeezed = true
	tile = Iso.to_grid(position)
	_squeeze_sprite()
	$Sprite.position = Vector2.ZERO
	$Collision.disabled = true
	
	squeezed.emit()


func release() -> void:
	is_squeezed = false
	_release_sprite()
	$Collision.disabled = false
	
	released.emit()



# internal

func _ready() -> void:
	controllable = controllable


func _physics_process(_delta: float) -> void:
	if not controllable or is_squeezed: return
	
	velocity = Iso.from_grid(Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)) * 8
	
	if velocity:
		move_and_slide()
	else:
		position = position.lerp(Iso.snap(position), 0.25)
	
	$Sprite.position = Iso.snap(position) - position


func _unhandled_key_input(_event: InputEvent) -> void:
	if not controllable: return
	
	if Input.is_action_pressed("interact"):
		release() if is_squeezed else squeeze()
	
	elif is_squeezed:
		var input: Vector2i
		if Input.is_action_pressed("move_down"): input = Vector2i.DOWN
		elif Input.is_action_pressed("move_up"): input = Vector2i.UP
		elif Input.is_action_pressed("move_left"): input = Vector2i.LEFT
		elif Input.is_action_pressed("move_right"): input = Vector2i.RIGHT
		else: return
		
		body.force_update_transform()
		if not body.test_move(body.transform, Iso.from_grid(input)):
			tile += input
			tile_changed.emit()
			create_tween().tween_property(self, "position", Iso.from_grid(tile), 0.05)


func _on_body_entered(body: Node2D) -> void:
	if not is_squeezed:
		body_entered.emit(body)


func _on_body_exited(_body: Node2D) -> void:
	if not is_squeezed and not $Area.get_overlapping_bodies():
		emptied.emit()


func _squeeze_sprite() -> void:
	$Sprite.region_rect.position.x = 34


func _release_sprite() -> void:
	$Sprite.region_rect.position.x = 0
