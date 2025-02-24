extends Node

var player: Player
var battle: Battle

var file := ConfigFile.new()

@onready var cursor: Sprite2D = $Overlay/Cursor


func change_scene(filename: String, target_gate: String = "") -> void:
	get_tree().change_scene_to_file("res://scenes/places/%s.tscn" % filename)
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
