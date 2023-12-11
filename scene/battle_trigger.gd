class_name BattleTrigger extends Area2D

@export var actors: Array[NodePath]


func _ready() -> void:
	monitorable = false
	body_entered.connect(on_body_entered)


func on_body_entered(body: PhysicsBody2D) -> void:
	if body is ActorNode:
		body.move(Iso.snap(body.position))
		var array: Array[Actor] = []
		for node in actors: array.append(get_node(node).data)
		Battle.start(array)
		queue_free()


func _draw():
	draw_polyline([get_child(0).shape.a, get_child(0).shape.b], Color("#ff000040"), 4)
