extends Node

var player: Player
var battle: Battle

var grid := IsoGrid.new()

@onready var menu: ItemList = $ContextMenu


func change_scene(filename: String, target_gate: String = "") -> void:
	get_tree().change_scene_to_file("res://place/%s.tscn" % filename)
	await get_tree().tree_changed
	if target_gate: get_tree().call_group("gate", "receive", target_gate)
