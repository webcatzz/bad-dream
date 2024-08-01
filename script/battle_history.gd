class_name BattleHistory extends UndoRedo


func record_motion(motion: Vector2i) -> void:
	create_action("motion")
	
	add_undo_method(Battle.current_actor.unpath)
	
	add_do_method(Battle.current_actor.add_to_path)
	add_do_method(Battle.current_actor.move_by.bind(motion))
	
	commit_action()


func record_action() -> void:
	create_action("action")
	
	#add_do_method(actor.r.bind(actor.position + motion))
	
	commit_action()
