extends Node2D


var active: bool
var current_tween: Tween

@onready var parent: Node = get_parent()


# Shows the save point UI.
func _on_player_entered() -> void:
	active = true
	_resize_color_rect()
	$UI/Margins/Saves/File01.grab_focus()
	
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
	current_tween.tween_property(Data.get_leader().node.get_node("Camera"), "offset:y", -32, 2).set_trans(Tween.TRANS_CUBIC)


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
	$UI.global_position = global_position - rect.size / 2 - Vector2(0, 32)
	$UI.size = rect.size + Vector2(0, 32)


func _save_to_file(idx: int) -> void:
	Data.save_file(idx)
