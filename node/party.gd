extends Node2D


const PATH_SEPARATION: int = 4
const FOLLOW_SPEED: float = 2.4

var player_node: ActorNode
var party_nodes: Array[ActorNode]

var input: Vector2
var path: PackedVector2Array

@onready var _camera: Camera2D = $Camera
@onready var _interaction_area: Area2D = $InteractionArea


func set_enabled(value: bool) -> void:
	set_process_unhandled_key_input(value)
	set_physics_process(value)
	input = Vector2.ZERO
	if value: _camera.make_current()



# internal

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if _interaction_area.has_overlapping_areas():
			_interaction_area.get_overlapping_areas()[0].interact()
			get_viewport().set_input_as_handled()
	else:
		input = Iso.from_grid(Input.get_vector("move_left", "move_right", "move_up", "move_down"))


func _physics_process(_delta: float) -> void:
	player_node.velocity = input * 8
	player_node.move_and_slide()
	
	if path[-1].distance_squared_to(player_node.position) > 256:
		path.remove_at(0)
		path.append(player_node.position)
	
	for party_node: ActorNode in party_nodes:
		party_node.resource.facing = Iso.to_grid(Iso.get_direction(
			Save.player.node.global_position - global_position
		))
		party_node.position = path[PATH_SEPARATION * Save.party.find(party_node.resource, 1)]


func _ready() -> void:
	Game.party_node = self
	
	# grabbing children
	var children: Array[Node] = get_children()
	
	# adding nodes
	for i: int in range(Save.party.size() - 1, -1, -1):
		var actor: Actor = Save.party[i]
		
		if not actor.node:
			actor.node = load("res://node/actor.tscn").instantiate()
			actor.node.resource = actor
			
			if i:
				actor.node.set_collision(false)
		
		actor.node.position = position
		add_child.call_deferred(actor.node)
	
	# setting variables
	player_node = Save.player.node
	for i: int in range(1, Save.party.size()):
		party_nodes.append(Save.party[i].node)
	
	# reparenting non-actor children
	for child: Node in children:
		child.reparent(player_node)
	
	# camera
	_camera.make_current.call_deferred()
	
	# path
	path.resize(PATH_SEPARATION * Save.party.size())
	path.fill(position)
