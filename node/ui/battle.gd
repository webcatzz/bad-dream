extends Node
## Battle UI manager.


@onready var _order: VBoxContainer = $Layer/Bars/Bottom/OrderWrapper/Scrollbox/Order


func _ready() -> void:
	$Animator.play("open")
	Battle.ended.connect($Animator.play.bind("close"))
	Battle.actor_added.connect(_on_actor_added)
	Battle.actor_removed.connect(_on_actor_removed)



# portraits

func _on_actor_added(actor: Actor, idx: int) -> void:
	var order_item: Control = preload("res://node/ui/order_item.tscn").instantiate()
	order_item.set_actor(actor)
	
	_order.add_child(order_item)
	_order.move_child(order_item, idx + 1)


func _on_actor_removed(idx: int) -> void:
	_order.get_child(idx).queue_free()
