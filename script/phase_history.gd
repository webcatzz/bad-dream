class_name PhaseHistory extends UndoRedo


var battle: Battle


func add_motion(actor: Actor, motion: Vector2i) -> void:
	create_action("motion")
	
	add_do_method(actor.add_to_path)
	add_do_method(actor.move_by.bind(motion))
	add_do_method(battle.selector.match_position.bind(actor.node))
	
	add_undo_method(actor.unpath)
	add_undo_method(battle.selector.match_position.bind(actor.node))
	
	commit_action()


func add_action() -> void:
	pass
