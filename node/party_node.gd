class_name PartyNode extends Node2D


const TRAIL_SEPARATION: int = 4

var leader_node: ActorNode
var party_nodes: Array[ActorNode]

var trail: PackedVector2Array

@onready var _camera: Camera2D = $Camera


func toggle(value: bool) -> void:
	set_process_unhandled_input(value)
	set_physics_process(value)
	
	if value:
		_camera.make_current()
	
	for party_node: ActorNode in party_nodes:
		party_node.set_collision(not value)



# internal


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("click"):
		leader_node.walk_to(get_global_mouse_position())
	
	if trail[0].distance_squared_to(leader_node.position) > 256:
		trail.remove_at(trail.size() - 1)
		trail.insert(0, leader_node.position)
	
	for i: int in party_nodes.size():
		party_nodes[i].walk_to(trail[TRAIL_SEPARATION * (i + 1)])


func _ready() -> void:
	Game.party_node = self
	
	# grabbing children
	var children: Array[Node] = get_children()
	
	# adding party nodes
	for i: int in range(Save.party.size() - 1, -1, -1):
		var actor: Actor = Save.party[i]
		
		if not actor.node:
			actor.node = load("res://node/actor_node.tscn").instantiate()
			actor.node.resource = actor
			
			if i:
				actor.node.set_collision(false)
		
		actor.node.position = position
		add_child.call_deferred(actor.node)
	
	# setting node variables
	leader_node = Save.leader.node
	for i: int in range(1, Save.party.size()):
		party_nodes.append(Save.party[i].node)
	
	# reparenting non-actor children
	for child: Node in children:
		child.reparent(leader_node)
	
	# camera
	_camera.make_current.call_deferred()
	
	# path
	trail.resize(TRAIL_SEPARATION * Save.party.size())
	trail.fill(position)
