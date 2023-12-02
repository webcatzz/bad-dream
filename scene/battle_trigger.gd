class_name BattleTrigger extends Area2D

@export var actors: Array[NodePath]


func _ready():
	monitorable = false
	body_entered.connect(on_body_entered)


func on_body_entered(body: PhysicsBody2D):
	if body is ActorNode:
		body.move(Iso.snap(body.position))
		var array: Array[Resource]
		for node in actors: array.append(get_node(node).data)
		Battle.start(array)
		queue_free()
