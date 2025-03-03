extends Node2D

var orphan_data: Array[ActorData]
var trait_list: PackedStringArray

@onready var default_data: ActorData = ResLib.actor_data.get_resource("default")
@onready var root: TypeGraphNode = $VBox/Root
@onready var orphan_list: HBoxContainer = $VBox/Orphans
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	for key: String in ResLib.actor_data.get_resource_list():
		var data: ActorData = ResLib.actor_data.get_resource(key)
		orphan_data.append(data)
		for t: String in data.traits:
			if t not in trait_list:
				trait_list.append(t)
	orphan_data.erase(default_data)
	
	populate_children(root)
	
	for data: ActorData in orphan_data:
		orphan_list.add_child(create_node(data))
	
	await get_tree().process_frame
	camera.position = root.actor_view.get_global_rect().get_center()
	camera.reset_smoothing()


func populate_children(node: TypeGraphNode) -> void:
	for t: String in trait_list:
		var traits: PackedStringArray = node.data.traits.duplicate()
		traits.insert(traits.bsearch(t), t)
		var data: ActorData = ResLib.actor_data.get_resource_by_traits(traits)
		if data != default_data:
			var child: TypeGraphNode = create_node(data)
			node.child(child)
			populate_children(child)


func create_node(data: ActorData) -> TypeGraphNode:
	var node: TypeGraphNode = preload("res://scenes/type_graph/type_graph_node.tscn").instantiate()
	node.data = data
	orphan_data.erase(data)
	return node
