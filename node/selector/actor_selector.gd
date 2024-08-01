extends Selector


@onready var _info: Control = $Info
@onready var _path: Line2D = $Path


func squeeze() -> bool:
	if super():
		Battle.current_actor = body.data
		_info.hide()
		_update_path()
		
		return true
	return false


func release() -> void:
	super()
	
	Battle.current_actor = null
	_info.show()
	_path.clear_points()



# virtual

func _can_squeeze(body: Node2D) -> bool:
	return body is ActorNode and body.data in Data.party


func _can_move(motion: Vector2i) -> bool:
	return body.data.can_move() and super(motion)



# internal

func _on_tile_changed() -> void:
	Battle.current_actor.extend_path()
	Battle.current_actor.move_to(tile)
	_update_path()


func _on_body_entered(body: Node2D) -> void:
	super(body)
	
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


func _update_path() -> void:
	_path.points = Battle.current_actor.path.map(func(point: Dictionary) -> Vector2:
		return Iso.from_grid(point.position)
	)
