extends Action


# TODO: make non-controllable actors move about randomly


func run() -> void:
	super()
	
	var leader_node: PlayerActorNode = Game.data.get_leader().node
	leader_node.input_mode = leader_node.InputMode.FREE
	leader_node.listening = true
	
	await Game.get_tree().create_timer(3).timeout
	
	leader_node.listening = false
	leader_node.input_mode = leader_node.InputMode.GRID
	leader_node.data.position = Iso.to_grid(leader_node.position)
