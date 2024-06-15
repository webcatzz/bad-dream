extends Action


func _get_strength() -> int:
	return cause.path.size() / 2
