class_name Splash extends Node2D
## Node representation of an [Action].


var action: Action ## The action this splash represents. When triggered, it will affect all [Actor]s in [member area].
var facing: Vector2i

var area: TileHighlight ## Displays area of effect and fetches [Actor]s in range.


## Returns an array of all overlapping [ActorNode]'s [Actor]s.
func get_actors() -> Array[Actor]:
	var array: Array[Actor] = []
	
	for body: PhysicsBody2D in area.get_overlapping_bodies():
		if body is ActorNode:
			array.append(body.data)
	
	return array


func finish() -> void:
	#if area:
		#action.cause.node.get_parent().add_child(SFX.new(
			#"bam!",
			#Iso.from_grid(action.cause.position) + area.position + area.polygon[0],
			#action.cause.facing
		#))
	
	queue_free()



# internal

func _init(action: Action, cause: Actor) -> void:
	self.action = action
	facing = cause.facing
	
	position = cause.node.position
	modulate = action.get_color()
	
	if action.shape:
		area = TileHighlight.node()
		area.body_entered.connect(queue_redraw.unbind(1))
		add_child(area)
		
		if action.shape is BitShape:
			area.from_bitshape(action.shape.turned(facing))
		elif action.shape is BitPath:
			area.from_bitpath(action.shape)


func _draw() -> void:
	if action.knockback_type and area:
		for actor: Actor in get_actors():
			draw_set_transform(actor.node.global_position - global_position)
			var end: Vector2 = Iso.from_grid(actor.calculate_knockback(Iso.rotate_grid_vector(action.knockback_vector, facing)))
			draw_line(Vector2.ZERO, end, Game.PALETTE.red, 8)
