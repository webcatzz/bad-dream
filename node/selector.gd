extends CharacterBody2D


signal actor_entered(actor: Actor)
signal emptied


func get_actor() -> Actor:
	return $Area.get_overlapping_bodies()[0].data



# internal

func _physics_process(_delta: float) -> void:
	if not visible: return
	
	if velocity:
		move_and_slide()
	else:
		position = position.lerp(Iso.snap(position), 0.25)
	
	$Sprite.position = Iso.snap(position) - position


func _unhandled_key_input(event: InputEvent) -> void:
	velocity = Iso.from_grid(Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)) * 8


func _on_body_entered(body: Node2D) -> void:
	actor_entered.emit(body.data)


func _on_body_exited(_body: Node2D) -> void:
	if not $Area.get_overlapping_bodies():
		emptied.emit()
