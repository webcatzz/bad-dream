class_name Cursor extends Node2D


enum Gesture {
	NONE,
	GRAB,
	FIST,
	KNOCK,
	LIMP,
}

@onready var _sprite: Sprite2D = $Sprite


func gesture(gesture: Gesture) -> void:
	match gesture:
		Gesture.NONE:
			_sprite.offset = Vector2(-4, -2)



# internal

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_viewport().get_mouse_position()
