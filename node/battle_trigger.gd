class_name BattleTrigger extends Area2D
## Triggers a battle once when the party leader crosses it.


## The list of [Actor]s added to battle on trigger.
@export var actors: Array[NodePath]


## Starts a battle with the party and [member actors].
func trigger() -> void:
	Game.data.leader.move(Iso.snap(Game.data.leader.position))
	
	var array: Array[Actor] = []
	for node in actors: array.append(get_node(node).data)
	
	Battle.start(array)
	queue_free()



# detecting bodies

func _ready() -> void:
	monitorable = false
	body_entered.connect(_on_body_entered)

# Calls [method trigger] if [param body] represents the party leader.
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.data == Game.data.leader: trigger()
