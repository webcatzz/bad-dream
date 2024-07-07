extends Action


func _countdown(cause: Actor, turns: int) -> void:
	run(cause)
	super(cause, turns)
