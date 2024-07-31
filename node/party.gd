extends Node2D


const SPEED: float = 60

var player_node: ActorNode
var party_nodes: Array[ActorNode]
var path: PackedVector2Array


func reset_path() -> void:
	path.resize(Data.party.size() * 4)
	path.fill(player_node.position)



# internal

func _ready() -> void:
	y_sort_enabled = true
	
	for i: int in range(Data.party.size() - 1, -1, -1):
		if not Data.party[i].node:
			Data.party[i].node = load("res://node/actor.tscn").instantiate()
			Data.party[i].node.data = Data.party[i]
		
		Data.party[i].node.position = position
		add_child.call_deferred(Data.party[i].node)
	
	player_node = Data.party[0].node
	for i: int in range(1, Data.party.size()):
		party_nodes.append(Data.party[i])
	
	reset_path()


func _unhandled_key_input(_event: InputEvent) -> void:
	if Battle.active: return
	
	player_node.velocity = Iso.from_grid(Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)) * 8


func _physics_process(_delta: float) -> void:
	if Battle.active: return
	
	player_node.move_and_slide()
	$Camera.position = player_node.position
	
	if path[-1].distance_squared_to(player_node.position) > 256:
		path.remove_at(0)
		path.append(player_node.position)
	
	for i: int in party_nodes.size():
		party_nodes[i].position = party_nodes[i].position.move_toward(
			path[i * 4],
			SPEED / 60
		)
