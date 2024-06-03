extends Node2D


var active: bool
var current_tween: Tween

@onready var parent: Node = get_parent()


func _on_player_entered() -> void:
	active = true
	_resize_color_rect()
	$UI/VBox/File01.grab_focus()
	
	Game.tween_opacity($UI, 0, 1, 2)
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween()
	current_tween.tween_property(Game.data.leader.node.get_node("Camera"), "offset:y", -32, 2).set_trans(Tween.TRANS_CUBIC)
	
	Game.data.leader.node.z_index = 101
	z_index = 101


func _on_player_exited() -> void:
	active = false
	
	await Game.tween_opacity($UI, 1, 0, 0.1)
	if current_tween: current_tween.kill()
	current_tween = get_tree().create_tween()
	current_tween.tween_property(Game.data.leader.node.get_node("Camera"), "offset:y", 0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	Game.data.leader.node.z_index = 0
	z_index = 0



# internal

func _ready() -> void:
	$Area.body_entered.connect(_call_if_body_is_leader.bind(_on_player_entered))
	$Area.body_exited.connect(_call_if_body_is_leader.bind(_on_player_exited))


func _call_if_body_is_leader(body: Node2D, callable: Callable) -> void:
	if body is ActorNode and body.data == Game.data.leader:
		callable.call()


func _resize_color_rect() -> void:
	var rect: Rect2 = get_viewport_rect()
	$UI.global_position = global_position - rect.size / 2
	$UI.size = rect.size


# rewrite later. just saves to one file no matter what
func _save_to_file(idx: int) -> void:
	Game.save(idx)
