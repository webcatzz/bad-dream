extends Node
## Battle UI manager.


var _following: Actor
var _old_camera_pos: Vector2

@onready var _status: Label = $Layer/Bars/Middle/Padding/Status
@onready var _order: VBoxContainer = $Layer/Bars/Bottom/Order/List/Scrollbox/Items
@onready var _camera: Camera2D = $Camera
@onready var _animator: AnimationPlayer = $Animator


func _ready() -> void:
	_animator.play("open")
	Battle.ended.connect(_animator.play.bind("close"))
	# order
	Battle.actor_added.connect(_on_actor_added)
	Battle.actor_removed.connect(_on_actor_removed)
	 # camera
	_camera.position = get_viewport().get_camera_2d().get_screen_center_position()
	_camera.make_current()
	_camera.reset_smoothing()
	Battle.turn_started.connect(_on_turn_started)


func run_status(string: String) -> void:
	_status.modulate.a = 1
	await _status.type(string)
	await get_tree().create_timer(2).timeout
	_animator.play(&"fade_status")


func pan_to(point: Vector2i) -> void:
	get_tree().paused = true
	_old_camera_pos = _camera.get_target_position()
	_camera.position = Iso.from_grid(point)
	#await get_tree().create_tween().tween_property(_camera, "position", Iso.from_grid(point), 1).set_trans(Tween.TRANS_CUBIC)


func pan_back() -> void:
	_camera.position = _old_camera_pos
	get_tree().paused = false
	#await get_tree().create_tween().tween_property(_camera, "position", _old_camera_pos, 1).set_trans(Tween.TRANS_CUBIC)



# order

func _on_actor_added(actor: Actor, idx: int) -> void:
	var order_item: Control = preload("res://node/ui/order_item.tscn").instantiate()
	order_item.set_actor(actor)
	
	_order.add_child(order_item)
	_order.move_child(order_item, idx + 1)


func _on_actor_removed(idx: int) -> void:
	_order.get_child(idx).queue_free()



# camera

func _on_turn_started(actor: Actor) -> void:
	if _following: _following.position_changed.disconnect(_set_camera_pos_from_grid)
	_following = actor
	
	_set_camera_pos_from_grid(actor.position)
	actor.position_changed.connect(_set_camera_pos_from_grid)


func _set_camera_pos_from_grid(point: Vector2) -> void:
	_camera.position = Iso.from_grid(point)
