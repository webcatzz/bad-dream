extends Node2D


var active: bool
var current_tween: Tween
var current_outlet: Button

@onready var outlets: HBoxContainer = $UI/Margins/VBox/Outlets
@onready var buttons: VBoxContainer = $UI/Margins/VBox/Buttons
@onready var plug: Sprite2D = outlets.get_node("Plug")


# Shows the save point UI.
func _on_player_entered() -> void:
	active = true
	_resize_color_rect()
	outlets.get_child(0).grab_focus()
	
	# background
	$Animator.play("show")
	
	# z-index
	z_index = 101
	for i: int in Data.party.size():
		Data.party[i].node.z_index = 101
		
		if i:
			get_tree().create_tween().tween_property(Data.party[i].node, "modulate:a", 0.25, 2)
	
	# camera
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween()
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", -120, 2).set_trans(Tween.TRANS_CUBIC)


# Hides the save point UI.
func _on_player_exited() -> void:
	active = false
	
	# background
	$Animator.play("hide")
	await $Animator.animation_finished
	
	# z-index
	z_index = 0
	for i: int in Data.party.size():
		Data.party[i].node.z_index = 0
		
		if i:
			get_tree().create_tween().tween_property(Data.party[i].node, "modulate:a", 1, 0.1)
	
	# camera
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween()
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", 0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)



# internal

func _ready() -> void:
	Battle.started.connect($Area.set_monitoring.bind(false))
	Battle.ended.connect($Area.set_monitoring.bind(true))


func _resize_color_rect() -> void:
	var rect: Rect2 = get_viewport_rect()
	$UI.global_position = global_position - rect.size / 2 - Vector2(0, 120)
	$UI.size = rect.size + Vector2(0, 120)


func _on_outlet_selected(idx: int) -> void:
	current_outlet = outlets.get_child(idx)
	
	buttons.get_child(0).grab_focus()
	
	await get_tree().create_tween().tween_property(plug, "position", current_outlet.position + current_outlet.size / 2, 0.25).set_trans(Tween.TRANS_CUBIC).finished
	$Animator.play("plug_in")


func _on_cancel_pressed() -> void:
	current_outlet.grab_focus()
	$Animator.play("plug_out")
