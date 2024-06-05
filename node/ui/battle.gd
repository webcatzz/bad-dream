extends CanvasLayer


func _ready() -> void:
	Battle.started.connect($Animator.play.bind("open"))
	Battle.ended.connect($Animator.play.bind("close"))
	Battle.actor_added.connect(add_portrait)
	Battle.actor_removed.connect(remove_portrait)


func add_portrait(actor: Actor, idx: int) -> void:
	var portrait: Control = preload("res://node/ui/portrait.tscn").instantiate()
	portrait.set_actor(actor)
	$VBox/BarTop/Order.add_child(portrait)
	$VBox/BarTop/Order.move_child(portrait, idx)


func remove_portrait(idx: int) -> void:
	$VBox/BarTop/Order.get_child(idx).queue_free()
