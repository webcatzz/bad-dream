extends Action


func _get_strength() -> int:
	return cause.node.path.size() / 2
