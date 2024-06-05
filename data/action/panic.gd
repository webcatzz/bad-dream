extends Action


func run() -> void:
	Game.data.get_leader().node.input_mode = PlayerActorNode.InputMode.FREE
	await Game.get_tree().create_timer(3).timeout
	Game.data.get_leader().node.input_mode = PlayerActorNode.InputMode.GRID
