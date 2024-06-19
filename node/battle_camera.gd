extends Camera2D
## Camera used during battle.


var following: Actor


func follow_actor(actor: Actor) -> void:
	if following: following.position_changed.disconnect(_set_position_from_grid)
	following = actor
	
	_set_position_from_grid(actor.position)
	actor.position_changed.connect(_set_position_from_grid)


func focus_point(actor: Actor) -> void:
	pass



# internal

func _ready() -> void:
	position_smoothing_enabled = true
	Battle.started.connect(_on_battle_started)
	Battle.turn_started.connect(follow_actor)


func _on_battle_started() -> void:
	position = get_viewport().get_camera_2d().get_screen_center_position()
	make_current()
	reset_smoothing()


func _set_position_from_grid(point: Vector2i) -> void:
	position = Iso.from_grid(point)
