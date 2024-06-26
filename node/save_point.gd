extends Node2D # TODO: fix weird focus behavior/make it auto-cancel when leaving


var active: bool
var current_tween: Tween
var selected_file: int

@onready var outlets: HBoxContainer = $UI/Margins/VBox/Outlets
@onready var buttons: Control = $UI/Margins/VBox/Buttons
@onready var plug: Sprite2D = outlets.get_node("Plug")


# Shows the save point UI.
func _on_player_entered() -> void:
	active = true
	
	get_tree().create_tween().tween_property(Data.get_leader().node, "global_position", global_position, 0.6).set_trans(Tween.TRANS_QUAD)
	#Data.get_leader().position = Iso.to_grid(global_position)
	_resize_color_rect()
	outlets.get_child(0).grab_focus()
	
	# background
	$Animator.play("intro")
	
	# camera
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween().set_parallel()
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", -120, 2).set_trans(Tween.TRANS_CUBIC)
	
	# z-index
	z_index = 101
	for i: int in Data.party.size():
		Data.party[i].node.z_index = 101
		
		if i:
			current_tween.tween_property(Data.party[i].node, "modulate:a", 0.25, 2)


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
	for i: int in Data.party.size():
		Data.party[i].node.z_index = 0
		
		if i:
			current_tween.tween_property(Data.party[i].node, "modulate:a", 1, 0.1)



# internal

func _ready() -> void:
	Battle.started.connect($Area.set_monitoring.bind(false))
	Battle.ended.connect($Area.set_monitoring.bind(true))


func _resize_color_rect() -> void:
	var rect: Rect2 = get_viewport_rect()
	$UI.global_position = global_position - rect.size / 2 - Vector2(0, 120)
	$UI.size = rect.size + Vector2(0, 120)


func _on_outlet_selected(idx: int) -> void:
	selected_file = idx + 1
	var current_outlet: Button = outlets.get_child(idx)
	
	buttons.get_child(0).grab_focus()
	
	await get_tree().create_tween().tween_property(plug, "position", current_outlet.position + current_outlet.size / 2, 0.25).set_trans(Tween.TRANS_CUBIC).finished
	$Animator.play("plug_in")


func _on_save_pressed():
	Data.save_file(selected_file)


func _on_load_pressed():
	Data.load_file(selected_file)


func _on_delete_pressed():
	pass # Replace with function body.


func _on_cancel_pressed() -> void:
	outlets.get_child(selected_file - 1).grab_focus()
	selected_file = -1
	$Animator.play("plug_out")
