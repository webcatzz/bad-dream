extends Node


# state
var current_place: String
var battle: Battle
var hovered: Node2D
# nodes
var party_node: Node2D
@onready var cursor: Cursor = $CanvasLayer/Cursor
@onready var context_menu: PanelContainer = $CanvasLayer/ContextMenu
# grid
var grid: AStarGrid2D = load("res://script/grid.gd").new()


func set_place(key: String) -> void:
	current_place = key
	get_tree().change_scene_to_file("res://place/%s.tscn" % key)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	grid.regenerate(get_tree().current_scene.tilemap)



# input

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		get_viewport().get_texture().get_image().save_png("user://screenshot_%s.png" % Time.get_datetime_string_from_system())
		print("took screenshot!")
		get_viewport().set_input_as_handled()



# internal

func _ready() -> void:
	get_window().mouse_entered.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_HIDDEN))
	get_window().mouse_exited.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_VISIBLE))
	
	if Save.file.get_value("debug", "draw_grid", false):
		add_child(load("res://node/grid_drawer.tscn").instantiate())


func _mouse_moved() -> void:
	pass
