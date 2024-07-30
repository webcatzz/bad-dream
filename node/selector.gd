extends CharacterBody2D


signal actor_entered(actor: Actor)
signal emptied


func _physics_process(_delta: float) -> void:
	if not visible: return
	
	if Game.input:
		velocity = Game.input * 8
		move_and_slide()
	else:
		position = position.lerp(Iso.snap(position), 0.25)
	
	$Sprite.position = Iso.snap(position) - position


func _on_body_entered(body: Node2D) -> void:
	actor_entered.emit(body.data)


func _on_body_exited(_body: Node2D) -> void:
	if not $Area.get_overlapping_bodies():
		emptied.emit()
