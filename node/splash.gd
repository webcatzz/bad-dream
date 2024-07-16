class_name Splash extends Node2D
## Node representation of an [Action].


var action: Action ## The action this splash represents. When triggered, it will affect all [Actor]s in [member area].
var cause: Actor

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
	self.cause = cause
	
	position = cause.node.position
	modulate = action.get_color()
	z_index = -1
	
	if action.shape:
		area = TileHighlight.node()
		
		if action.shape is BitShape:
			area.from_bitshape(action.shape.turned(cause.facing))
		elif action.shape is BitPath:
			area.from_bitpath(action.shape)
		
		if action.knockback_type:
			area.body_entered.connect(_on_body_entered_or_exited.unbind(1))
			area.body_exited.connect(_on_body_entered_or_exited.unbind(1))
		
		add_child(area)


func _on_body_entered_or_exited() -> void:
	for i: int in range(get_child_count(), 1):
		remove_child(get_child(i))
	
	for actor: Actor in get_actors():
		var arrow: Line2D = preload("res://node/tile_arrow.tscn").instantiate()
		add_child(arrow)
		arrow.set_ends(
			actor.position,
			actor.position + actor.calculate_knockback(Iso.rotate_grid_vector(action.knockback_vector, cause.facing))
		)
