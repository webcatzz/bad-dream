class_name Splash extends Node2D
## Node representation of an [Action]. Delivers actions to [Actor]s during battle.


## The action to deliver. When triggered, it will affect all [Actor]s in range.
var action: Action

## A [TileHighlight] used to display area of effect and fetch [Actor]s in range.
var area: TileHighlight = TileHighlight.node()


func _init(action: Action) -> void:
	self.action = action


func _ready() -> void:
	#position = Iso.turn(Iso.from_cart(action.shape_offset), action.cause.facing)
	action.triggered.connect(trigger)
	
	area.from_bitshape(action.get_bitshape())
	
	add_child(area)


## Affects all actors in range with [member action].
func trigger() -> void:
	var did_affect_actors: bool = false
	
	for body in area.get_overlapping_bodies():
		if body is ActorNode:
			action.affect(body.data)
			did_affect_actors = true
	
	action.cause.node.get_parent().add_child(SFX.new(
		"bam!" if did_affect_actors else "...?",
		Vector2(action.cause.position) + area.position + area.polygon[0],
		action.cause.facing
	))
	queue_free()
