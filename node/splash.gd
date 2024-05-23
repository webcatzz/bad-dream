class_name Splash extends Node2D
## Node representation of an [Action]. Delivers actions to [Actor]s during battle.


## The action to deliver. When triggered, it will affect all [Actor]s in range.
var action: Action

## A [TileHighlight] used to display area of effect and fetch [Actor]s in range.
var area: TileHighlight


func _init(action: Action) -> void:
	self.action = action


func _ready() -> void:
	position = Iso.turn(Iso.from_cart(action.splash_offset), action.cause.facing)
	action.triggered.connect(trigger)
	
	if not area: area = TileHighlight.node()
	match action.splash_shape:
		action.Shape.SQUARE:
			var size: Vector2 = Vector2(action.splash_size, action.splash_size)
			area.position = -Iso.from_cart(size) / 2
			
			var bitmap: BitMap = BitMap.new()
			bitmap.create(size)
			bitmap.set_bit_rect(Rect2i(Vector2.ZERO, size), true)
			area.from_bitmap(bitmap)
	add_child(area)


## Affects all actors in range with [member action].
func trigger() -> void:
	var did_affect_actors: bool = false
	
	for body in area.get_overlapping_bodies():
		if body is ActorNode:
			action.affect(body.data)
			did_affect_actors = true
	
	# fix regarding data.cause.node.get_parent(): hacky. waiting for sfx's finished signal and then queue_free()ing doesnt seem to work it just queue_free()s immediately???
	# ^ no idea what i was trying to say here
	action.cause.node.get_parent().add_child(SFX.new(
		"bam!" if did_affect_actors else "...?",
		Vector2(action.cause.position) + area.position + area.polygon[0],
		action.cause.facing
	))
	queue_free()
