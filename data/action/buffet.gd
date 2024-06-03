extends Action


func _decrement_delay() -> void:
	for actor: Actor in _get_affected_actors():
		actor.push(Vector2(knockback_vector).rotated(atan2(cause.facing.y, cause.facing.x)))
	
	super()
