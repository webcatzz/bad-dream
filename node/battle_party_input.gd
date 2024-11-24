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

@onready var path_line: Line2D = $Path
@onready var mouse_path_line: Line2D = $MousePath


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
	var extra_path: Array[Vector2i] = Game.grid.get_id_path(path_stops[-1], tile).slice(1)
	if can_add_to_path(extra_path.size()):
		path_stops.append(tile)
		path.append_array(extra_path)
		for point: Vector2i in Game.grid.get_point_path(path_stops[-2], path_stops[-1]).slice(1):
			path_line.add_point(point)
	else:
		pass


func clear_path() -> void:
	path_stops.clear()
	path.clear()
	path_line.clear_points()


func can_add_to_path(points: int) -> bool:
	return path.size() + points < current_actor.stamina



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
			
			elif event is InputEventMouseMotion:
				mouse_path_line.clear_points()
				for point: Vector2i in Game.grid.get_point_path(path_stops[-1], Game.grid.get_hovered_tile()):
					mouse_path_line.add_point(point)
				mouse_path_line.default_color = Palette.WHITE if can_add_to_path(mouse_path_line.get_point_count() - 1) else Palette.RED
