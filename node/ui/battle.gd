extends Node
## Battle UI manager.


var _following: Actor

var _camera_control: bool
var _camera_input: Vector2

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
	Battle.turn_started.connect(_on_turn_started)
	 # camera
	_camera.position = get_viewport().get_camera_2d().get_screen_center_position()
	_camera.make_current()
	_camera.reset_smoothing()
	Battle.turn_started.connect(_follow_actor)


func run_status(string: String) -> void:
	_status.modulate.a = 1
	await _status.type(string)
	await get_tree().create_timer(2).timeout
	_animator.play(&"fade_status")



# order

func _on_turn_started(actor: Actor) -> void:
	$Layer/Bars/Top/CurrentActor.update(actor)
	var scrollbox: ScrollContainer = $Layer/Bars/Bottom/Order/List/Scrollbox
	get_tree().create_tween().tween_property(
		scrollbox, "scroll_vertical",
		scrollbox.get_child(0).get_child((Battle.current_idx + 1) % Battle.order.size()).offset_top,
		0.25
	).set_trans(Tween.TRANS_CUBIC)


func _on_actor_added(actor: Actor, idx: int) -> void:
	var order_item: Control = preload("res://node/ui/order_item.tscn").instantiate()
	order_item.set_actor(actor)
	
	_order.add_child(order_item)
	_order.move_child(order_item, idx)


func _on_actor_removed(idx: int) -> void:
	_order.get_child(idx).queue_free()



# camera

func _follow_actor(actor: Actor) -> void:
	if _following: _following.position_changed.disconnect(_set_camera_pos_from_grid)
	_camera_control = false
	_following = actor
	
	_set_camera_pos_from_grid(actor.position)
	actor.position_changed.connect(_set_camera_pos_from_grid)


func _set_camera_pos_from_grid(point: Vector2) -> void:
	_camera.position = Iso.from_grid(point)


func freefloat() -> void:
	if _following: _following.position_changed.disconnect(_set_camera_pos_from_grid)
	_camera_control = true


func _unhandled_key_input(event: InputEvent):
	if _camera_control:
		_camera_input = Iso.from_grid(Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down"),
		)).normalized() * 4


func _process(_delta: float) -> void:
	if _camera_control:
		_camera_input
