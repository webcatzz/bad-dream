extends Action


func affect(actor: Actor) -> void:
	strength = cause.node.path.size()
	super(actor)
