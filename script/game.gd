extends Node2D


signal clicked(point: Vector2)


# state
var current_place: String
var battle: Battle
var hovered: Node2D
# control
var party_node: Node2D
@onready var cursor: Cursor = $CanvasLayer/Cursor
@onready var context_menu: PanelContainer = $CanvasLayer/ContextMenu
# music
@onready var _music: AudioStreamPlayer = $Music
@onready var _music_animator: AnimationPlayer = $Music/Animator
# pathing
var grid: AStarGrid2D = load("res://script/grid.gd").new()


func set_place(key: String) -> void:
	current_place = key
	get_tree().change_scene_to_file("res://place/%s.tscn" % key)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	if get_tree().current_scene.tilemap:
		grid.generate(get_tree().current_scene.tilemap)



# music

func play_music(filename: String) -> void:
	var file: AudioStreamMP3 = load("res://asset/music/%s.mp3" % filename)
	_music.stream = file
	_music.play()


func stop_music() -> void:
	_music.paused = true



# input

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		clicked.emit(get_global_mouse_position())


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		get_viewport().get_texture().get_image().save_png("user://screenshot_%s.png" % Time.get_datetime_string_from_system())
		print("took screenshot!")
		get_viewport().set_input_as_handled()



# internal

func _ready() -> void:
	get_window().mouse_entered.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_HIDDEN))
	get_window().mouse_exited.connect(Input.set_mouse_mode.call_deferred.bind(Input.MOUSE_MODE_VISIBLE))
	
	# debug
	if Save.file.get_value("debug", "draw_grid", false):
		add_child(load("res://node/debug/grid_drawer.tscn").instantiate())
	if Save.file.get_value("debug", "draw_party_path", false):
		add_child(load("res://node/debug/party_path_drawer.gd").new())


func _mouse_moved() -> void:
	pass
