extends Node


# state
var current_place: String
var battle: Battle
# nodes
var party_node: Node2D


func set_place(key: String) -> void:
	current_place = key
	get_tree().change_scene_to_file("res://place/%s.tscn" % key)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		get_viewport().get_texture().get_image().save_png("user://screenshot_%s.png" % Time.get_datetime_string_from_system())
		print("took screenshot!")
		get_viewport().set_input_as_handled()
