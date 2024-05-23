class_name ActorNode extends CharacterBody2D
## Node representation of an [Actor].

@export var data: Actor = Actor.new()


func _ready() -> void:
	data.node = self
	data.position = position
	
	data.position_changed.connect(move.bind(false))
	data.facing_changed.connect(_set_facing)
	
	data.turn_started.connect($WhileSelected.set_visible.bind(true))
	data.turn_ended.connect($WhileSelected.set_visible.bind(false))
	data.health_changed_by.connect(_on_health_changed_by)
	data.defeated.connect(_on_defeated)


func take_turn():
	await UI.get_tree().create_timer(0.5).timeout
	data.turn_ended.emit()


func move(pos: Vector2, update_data: bool = true) -> void:
	if update_data: data.move(pos)
	create_tween().tween_property(self, "position", pos, 0.05)


## Faces the sprite and collision raycast toward [param direction].
func _set_facing(direction: Vector2) -> void:
	$Facing.set_point_position(1, direction)
	$Sprite.frame_coords.x = Iso.to_idx(direction)


func _on_health_changed_by(value: int):
	if value < 0: $Animator.play("damaged")


func _on_defeated():
	$Collision.disabled = true
	await $Animator.animation_finished
	$Animator.play("defeated")
	await $Animator.animation_finished
	queue_free()
