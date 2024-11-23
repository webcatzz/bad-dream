extends Node2D


enum State {
	DISABLED = -1,
	IDLE,
	MOVING,
	ACTING,
}

var state: State = State.DISABLED
var current_actor: Actor

var path_stops: Array[Vector2i]
var path: Array[Vector2i]


func toggle(value: bool):
	state = State.IDLE if value else State.DISABLED
	for actor: Actor in Save.party:
		actor.node.input.toggle(value)



# movement

func start_moving_actor(actor: Actor) -> void:
	state = State.MOVING
	current_actor = actor
	current_actor.node.sprite.position.y = -4
	path_stops.append(current_actor.position)


func stop_moving_actor() -> void:
	state = State.DISABLED
	current_actor.node.sprite.position.y = 0
	
	await current_actor.follow_path(path)
	clear_path()
	
	state = State.IDLE


func add_path_stop(tile: Vector2i) -> void:
	path_stops.append(tile)
	path.clear()
	for i: int in range(1, path_stops.size()):
		path.append_array(Game.grid.get_id_path(path_stops[i - 1], path_stops[i]))
	queue_redraw()


func clear_path() -> void:
	path_stops.clear()
	path.clear()
	queue_redraw()



# other

func open_actor_menu(actor: Actor) -> void:
	Game.context_menu.add_option("Act", load("res://asset/ui/icon/attack.png"))
	Game.context_menu.add_option("Pocket", load("res://asset/ui/icon/pocket.png"))
	Game.context_menu.open("Actor")
	
	match await Game.context_menu.chosen:
		0:
			pass


func ready_actor(actor: Actor) -> void:
	actor.node.input.gui_input.connect(_actor_input.bind(actor))


func _actor_input(event: InputEvent, actor: Actor) -> void:
	match state:
		State.IDLE:
			if event.is_action_pressed("click"):
				start_moving_actor(actor)


func _unhandled_input(event: InputEvent) -> void:
	match state:
		State.MOVING:
			if event.is_action_pressed("click"):
				var tile: Vector2i = Game.grid.get_hovered_tile()
				if path_stops and path_stops[-1] == tile:
					stop_moving_actor()
				elif not Game.grid.is_point_solid(tile):
					add_path_stop(tile)
	
	if state != State.DISABLED and event is InputEventMouseMotion:
		queue_redraw()


func _draw() -> void:
	draw_colored_polygon(Iso.get_tile_points(Game.grid.get_hovered_tile()), Color(1, 1, 1, 0.1))
	
	if path:
		var points: PackedVector2Array
		for tile: Vector2i in path:
			points.append(Game.grid.get_point_position(tile))
		draw_polyline(points, Color.BLACK, 8)
		
		var mouse_path: PackedVector2Array = Game.grid.get_point_path(path[-1], Game.grid.get_hovered_tile())
		if mouse_path:
			draw_polyline(mouse_path, Color(0, 0, 0, 0.25), 8)
