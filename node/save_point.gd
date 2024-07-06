extends Node2D


var active: bool
var current_tween: Tween
var selected_file: int = 1
var file_selected: bool

@onready var _buttons: VBoxContainer = $UI/Margins/Controls/Buttons
@onready var _plug = $UI/Margins/Plug


# Shows the save point UI.
func _on_player_entered() -> void:
	active = true
	
	get_tree().create_tween().tween_property(Data.get_leader().node, "global_position", global_position, 0.6).set_trans(Tween.TRANS_QUAD)
	_resize_color_rect()
	
	# background
	$Animator.play("intro")
	
	# camera
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween().set_parallel()
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", -120, 2).set_trans(Tween.TRANS_CUBIC)
	
	# z-index
	z_index = 101
	Data.get_leader().node.z_index = 101


# Hides the save point UI.
func _on_player_exited() -> void:
	active = false
	
	# background
	$Animator.play("outro")
	await $Animator.animation_finished
	
	# camera
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween().set_parallel()
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", 0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# z-index
	z_index = 0
	Data.get_leader().node.z_index = 0



# internal

func _ready() -> void:
	Battle.started.connect($Area.set_monitoring.bind(false))
	Battle.ended.connect($Area.set_monitoring.bind(true))


func _resize_color_rect() -> void:
	var rect: Rect2 = get_viewport_rect()
	$UI.global_position = global_position - rect.size / 2 - Vector2(0, 120)
	$UI.size = rect.size + Vector2(0, 120)



# plug controls

func _input(event: InputEvent) -> void:
	if not $UI.visible or file_selected: return
	
	if event.is_action_pressed("ui_down"):
		selected_file = (selected_file + 1) % 3
		_move_plug(get_node("UI/Margins/Port" + str(selected_file)).position)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		selected_file = wrapi(selected_file - 1, 0, 3)
		_move_plug(get_node("UI/Margins/Port" + str(selected_file)).position)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		file_selected = true
		$Animator.play("plug_in")
		_buttons.get_child(0).grab_focus()
		get_viewport().set_input_as_handled()


func _move_plug(point: Vector2) -> void:
	get_tree().create_tween().tween_property(_plug, "position", point, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _cancel() -> void:
	file_selected = false
	$Animator.play("plug_out")
	get_viewport().gui_get_focus_owner().release_focus()



# file management

func _on_save_pressed():
	Data.save_file(selected_file)


func _on_load_pressed():
	Data.load_file(selected_file)


func _on_delete_pressed():
	pass # Replace with function body.
