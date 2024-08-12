extends Node


# state
var current_place: String
var current_battle: Battle
# nodes
var party_node: Node2D


func set_place(key: String) -> void:
	current_place = key
	get_tree().change_scene_to_file("res://place/%s.tscn" % key)
