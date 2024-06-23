class_name Splash extends Node2D
## Node representation of an [Action].


var action: Action ## The action this splash represents. When triggered, it will affect all [Actor]s in [member area].

var area: TileHighlight ## Displays area of effect and fetches [Actor]s in range.


## Returns an array of all overlapping [ActorNode]'s [Actor]s.
func get_actors() -> Array[Actor]:
	var array: Array[Actor] = []
	
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
		area.body_entered.connect(queue_redraw.unbind(1))
		add_child(area)
		_update_area_shape()


# Updates position and facing direction.
func _enter_tree() -> void:
	position = action.cause.node.position
	if area: _update_area_shape()


# Updates area facing direction.
func _update_area_shape() -> void:
	if action.shape is BitShape:
		area.from_bitshape(action.shape.turned(action.cause.facing))
	elif action.shape is BitPath:
		area.from_bitpath(action.shape)


func _draw() -> void:
	if area:
		for actor: Actor in get_actors():
			draw_set_transform(actor.node.global_position - global_position)
			var end: Vector2 = Iso.from_grid(actor.calculate_knockback(Iso.rotate_grid_vector(action.knockback_vector, action.cause.facing)))
			draw_line(Vector2.ZERO, end, Color.RED, 8)


func _on_finished() -> void:
	#if area:
		#action.cause.node.get_parent().add_child(SFX.new(
			#"bam!" if successful else "...?",
			#Iso.from_grid(action.cause.position) + area.position + area.polygon[0],
			#action.cause.facing
		#))
	
	get_parent().remove_child(self)
