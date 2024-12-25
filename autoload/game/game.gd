extends Node

var player: Player
var battle: Battle

var grid := IsoGrid.new()

@onready var menu: ItemList = $ContextMenu


func change_scene(filename: String, target_gate: String = "") -> void:
	get_tree().change_scene_to_file("res://place/%s.tscn" % filename)
	await get_tree().tree_changed
	
	for gate: Node2D in get_tree().get_nodes_in_group("gate"):
		if gate.name == target_gate:
			gate.receive()
			break
