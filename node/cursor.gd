extends Node2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_viewport().get_mouse_position()
