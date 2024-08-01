class_name Selector extends CharacterBody2D


@export var controllable: bool = true

var tile: Vector2i
var body: Node2D
var is_squeezed: bool = false


func squeeze() -> void:
	is_squeezed = true
	tile = Iso.to_grid(body.position)
	$Collision.disabled = true
	$Area.monitoring = false
	_squeeze_sprite()


func release() -> void:
	is_squeezed = false
	$Collision.disabled = false
	$Area.monitoring = true
	_release_sprite()


func move(motion: Vector2i) -> void:
	_set_position(tile + motion)


func set_controllable(value: bool) -> void:
	controllable = value
	$Camera.enabled = value
	if controllable: $Camera.make_current()



# virtual

func _can_squeeze(_body: Node2D) -> bool:
	return true


func _can_move(motion: Vector2i) -> bool:
	body.force_update_transform()
	return not body.test_move(body.transform, Iso.from_grid(motion))


func _on_body_entered(_body: Node2D) -> void:
	pass


func _on_body_exited(_body: Node2D) -> void:
	pass



# internal

func _ready() -> void:
	set_controllable(controllable)


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
		if is_squeezed:
			release()
		elif $Area.has_overlapping_bodies():
			body = $Area.get_overlapping_bodies()[0]
			if _can_squeeze(body):
				squeeze()
	
	elif is_squeezed:
		var input: Vector2i
		if Input.is_action_pressed("move_down"): input = Vector2i.DOWN
		elif Input.is_action_pressed("move_up"): input = Vector2i.UP
		elif Input.is_action_pressed("move_left"): input = Vector2i.LEFT
		elif Input.is_action_pressed("move_right"): input = Vector2i.RIGHT
		
		if input and _can_move(input):
			move(input)


func _set_position(tile: Vector2i) -> void:
	self.tile = tile
	create_tween().tween_property(self, "position", Iso.from_grid(tile), 0.05)


func _squeeze_sprite() -> void:
	$Sprite.region_rect.position.x = 34
	$Sprite.position = Vector2.ZERO


func _release_sprite() -> void:
	$Sprite.region_rect.position.x = 0
