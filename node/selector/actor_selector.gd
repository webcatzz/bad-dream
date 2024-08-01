extends Selector


@onready var _info: Control = $Info
@onready var _path: Line2D = $Path


func squeeze() -> void:
	super()
	
	Battle.current_actor = body.data
	_info.hide()
	_update_path()
	
	Battle.current_actor.reoriented.connect(_on_actor_reoriented)


func release() -> void:
	super()
	
	Battle.current_actor.reoriented.disconnect(_on_actor_reoriented)
	
	Battle.current_actor = null
	_info.show()
	_path.clear_points()


func move(motion: Vector2i) -> void:
	Battle.history.record_motion(motion)



# internal

func _can_squeeze(body: Node2D) -> bool:
	return body is ActorNode and body.data in Data.party


func _can_move(motion: Vector2i) -> bool:
	return body.data.can_move() and super(motion)


func _on_body_entered(body: Node2D) -> void:
	if is_squeezed: return
	
	var actor: Actor = body.data
	var controls: Array[Control] = []
	
	if actor.traits:
		var traits: VBoxContainer = VBoxContainer.new()
		traits.add_theme_constant_override("separation", 4)
		controls.append(traits)
		
		traits.add_child(Label.new())
		traits.get_child(0).text = "Traits"
		
		for trait_type: Trait.Type in actor.traits:
			traits.add_child(preload("res://node/ui/trait_label.tscn").instantiate())
			traits.get_child(-1).write(trait_type)
	
	_info.write({
		"title": actor.name,
		"controls": controls
	})
	_info.show()


func _on_body_exited(body: Node2D) -> void:
	if is_squeezed: return
	
	_info.hide()


func _update_path() -> void:
	_path.points = Battle.current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)


func _on_actor_reoriented() -> void:
	_set_position(Battle.current_actor.position)


func _set_position(tile: Vector2i) -> void:
	super(tile)
	_update_path()
