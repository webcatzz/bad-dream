class_name BattleTrigger extends Trigger


@export var actors: Array[NodePath] ## [Actor]s added to battle on trigger.


func trigger() -> void:
	super()
	var array: Array[Actor] = []
	array.resize(actors.size())
	
	for i: int in actors.size():
		array[i] = get_node(actors[i]).data
	
	Battle.start(array)
	
	queue_free()
