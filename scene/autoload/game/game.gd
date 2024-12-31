extends Node

var player: Player
var inventory := Inventory.new()

var battle: Battle
var grid := IsoGrid.new()

var file := ConfigFile.new()


func change_scene(filename: String, target_gate: String = "") -> void:
	get_tree().change_scene_to_file("res://place/%s.tscn" % filename)
	await get_tree().tree_changed
	
	for gate: Node2D in get_tree().get_nodes_in_group("gate"):
		if gate.name == target_gate:
			gate.receive()
			break



# save & load

func load_file() -> void:
	file.load("user://save.cfg")


func save_file() -> void:
	file.save("user://save.cfg")



# init

func _ready() -> void:
	load_file()