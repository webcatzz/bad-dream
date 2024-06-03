class_name BattleTrigger extends Trigger


## [Actor]s added to battle on trigger.
@export var actors: Array[NodePath]


func trigger() -> void:
	var array: Array[Actor] = []
	array.resize(actors.size())
	
	for i: int in actors.size():
		array[i] = get_node(actors[i]).data
	
	Battle.start(array)
	
	queue_free()
