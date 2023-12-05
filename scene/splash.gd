class_name Splash extends Area2D

var data: Action


func _init(data: Action):
	self.data = data
	data.delay_ended.connect(trigger)
	position = Iso.to_iso(data.splash_offset)
	
	var tile: PackedScene = load("res://scene/tile_highlight.tscn")
	match data.splash_shape:
		data.Shape.SQUARE:
			var area: Array = range(-data.splash_size/2, data.splash_size - data.splash_size/2)
			for y in area: for x in area:
				var t = tile.instantiate()
				t.position = Iso.to_iso(Vector2i(x, y))
				add_child(t)


func start():
	if data.delay:
		data.start_counting()
	else: trigger()


func trigger():
	for body in get_overlapping_bodies():
		body.data.affect(data)
	queue_free()
