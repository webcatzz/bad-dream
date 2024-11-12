class_name Cursor extends Node2D


enum Gesture {
	NONE,
	GRAB,
	FIST,
	KNOCK,
}


func gesture(gesture: Gesture) -> void:
	pass



# internal

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_viewport().get_mouse_position()
