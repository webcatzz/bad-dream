@tool class_name BattleTrigger extends Trigger


@export var actors: Array[NodePath] ## [Actor]s added to battle on trigger.
@export var region: Rect2i: ## Travellable space in battle.
	set(value): region = value; queue_redraw()


func trigger() -> void:
	super()
	var array: Array[Actor] = []
	array.resize(actors.size())
	
	for i: int in actors.size():
		array[i] = get_node(actors[i]).data
	
	region.position += Iso.to_grid(global_position)
	Battle.start(array, region)
	
	queue_free()



func _draw() -> void:
	if Engine.is_editor_hint():
		var points: PackedVector2Array = [
			region.position, Vector2(region.position.x, region.end.y),
			region.end, Vector2(region.end.x, region.position.y)
		]
		
		for i: int in points.size():
			points[i] = Iso.from_grid(points[i]) - Vector2(16, 0)
		
		draw_dashed_line(points[0], points[1], Color("#ff000040"), 1)
		draw_dashed_line(points[1], points[2], Color("#ff000040"), 1)
		draw_dashed_line(points[2], points[3], Color("#ff000040"), 1)
		draw_dashed_line(points[3], points[0], Color("#ff000040"), 1)
