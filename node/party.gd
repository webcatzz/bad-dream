extends Node2D


var input: Vector2

var player_node: ActorNode
var party_nodes: Array[ActorNode]

@onready var _camera: Camera2D = $Camera
@onready var _interaction_area: Area2D = $InteractionArea


func set_enabled(value: bool) -> void:
	set_process_unhandled_key_input(value)
	input = Vector2.ZERO
	if value: _camera.make_current()


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
		
		actor.node.position = position
		add_child.call_deferred(actor.node)
	
	# setting variables
	player_node = Save.player.node
	for i: int in range(1, Save.party.size()):
		party_nodes.append(Save.party[i].node)
	
	# reparenting children
	for child: Node in children:
		child.reparent(player_node)
	
	_camera.make_current.call_deferred()
