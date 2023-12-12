class_name ActorNode extends CharacterBody2D

@export var data: Actor = Actor.new()


func _ready() -> void:
	data.node = self
	data.position = position
	data.position_changed.connect(move.bind(false))
	data.turn_started.connect($WhileSelected.set_visible.bind(true))
	data.turn_ended.connect($WhileSelected.set_visible.bind(false))
	data.health_changed_by.connect(on_health_changed_by)
	data.defeated.connect(on_defeated)
	# test
	data.facing_changed.connect(set_facing)


func move(pos: Vector2, update_data: bool = true) -> void:
	if update_data: data.move(pos)
	create_tween().tween_property(self, "position", pos, 0.05)


func set_facing(direction: Vector2) -> void:
	$Facing.set_point_position(1, direction)


func take_turn():
	await UI.get_tree().create_timer(0.5).timeout
	data.turn_ended.emit()


func on_health_changed_by(value: int):
	if value < 0: $Animator.play("damaged")


func on_defeated():
	$Collision.disabled = true
	await $Animator.animation_finished
	queue_free()
