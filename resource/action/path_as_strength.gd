extends Action


func _get_strength(cause: Actor) -> int:
	return cause.path.size() / 2
