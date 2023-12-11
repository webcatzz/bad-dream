class_name Splash extends Area2D

var data: Action


func _init(data: Action) -> void:
	self.data = data
	self.monitorable = false
	data.delay_ended.connect(trigger)
	
	var tile: PackedScene = load("res://scene/tile_highlight.tscn")
	match data.splash_shape:
		data.Shape.SQUARE:
			var area: Array = range(-data.splash_size/2, data.splash_size - data.splash_size/2)
			for y: int in area: for x: int in area:
				var t: Node2D = tile.instantiate()
				t.position = Iso.to_iso(Vector2i(x, y))
				add_child(t)


func _ready() -> void: position = Iso.turn(Iso.to_iso(data.splash_offset), data.cause.facing)


func start() -> void:
	if data.delay: data.start_counting()
	else: trigger()


func trigger() -> void:
	# fix regarding data.cause.node.get_parent(): hacky. waiting for sfx's finished signal and then queue_free()ing doesnt seem to work it just queue_free()s immediately???
	if has_overlapping_bodies(): data.cause.node.get_parent().add_child(SFX.new("bam!", data.cause.facing, data.cause.position))
	else: data.cause.node.get_parent().add_child(SFX.new("...?", data.cause.facing, data.cause.position))
	for body in get_overlapping_bodies():
		body.data.affect(data)
	queue_free()
