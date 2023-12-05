extends VBoxContainer

var portrait_template: PackedScene = load("res://scene/ui/portrait.tscn")


func _ready():
	Battle.started.connect(UI.open.bind("battle"))
	Battle.ended.connect(UI.close.bind("battle"))
	Battle.actor_added.connect(add_portrait)
	Battle.actor_removed.connect(remove_portrait)


func add_portrait(actor: Resource, idx: int):
	var portrait: Control = portrait_template.instantiate()
	portrait.set_actor(actor)
	$BarTop/Order.add_child(portrait)
	$BarTop/Order.move_child(portrait, idx)


func remove_portrait(idx: int):
	$BarTop/Order.get_child(idx).queue_free()
