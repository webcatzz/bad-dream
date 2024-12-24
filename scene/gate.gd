class_name Gate
extends Node2D

@export var scene: String
@export var gate: String


func send() -> void:
	Game.change_scene(scene, gate)


func receive(target_gate: String) -> void:
	if name == target_gate:
		Game.player.global_position = global_position


# init

func _init() -> void:
	add_to_group("gate")
