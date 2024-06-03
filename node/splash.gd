class_name Splash extends Node2D
## Node representation of an [Action].


## The action to deliver. When triggered, it will affect all [Actor]s in range.
var action: Action

## A [TileHighlight] used to display area of effect and fetch [Actor]s in range.
var area: TileHighlight


## Returns an array of all overlapping [ActorNode]'s [Actor]s.
func get_actors() -> Array[Actor]:
	var array: Array[Actor]
	
	for body: Node2D in area.get_overlapping_bodies():
		if body is ActorNode:
			array.append(body.data)
	
	return array



# internal

func _init(action: Action) -> void:
	self.action = action
	action.splash = self


func _ready() -> void:
	action.finished.connect(_on_finished)
	
	if action.shape:
		area = TileHighlight.node()
		if action.shape is BitPath:
			action.shape.update()
			area.from_bitshape(action.shape)
		else:
			area.from_bitshape(action.shape.turned(action.cause.facing))
		add_child(area)


func _on_finished(successful: bool) -> void:
	if area:
		action.cause.node.get_parent().add_child(SFX.new(
			"bam!" if successful else "...?",
			Iso.from_grid(action.cause.position) + area.position + area.polygon[0],
			action.cause.facing
		))
	
	queue_free()
