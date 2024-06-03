class_name DialogueBubble extends DialogueLabel
## Speech bubble label.


var tail: Vector2


func run(string: String) -> void:
	Game.tween_opacity(self, 0, 1, 0.5)
	await get_tree().create_timer(0.25).timeout
	
	await super(string)
	
	await Game.tween_opacity(self, 1, 0, 0.25)
	queue_free()



# internal


func _init() -> void:
	super()
	size.x = 200
	theme_type_variation = &"DialogueBubble"
	material = preload("res://asset/dither_opacity.tres")


func _draw() -> void:
	var connecting_point: Vector2 = size / 2
	draw_colored_polygon([
		connecting_point + Vector2(-6, 0),
		connecting_point + Vector2(6, 0),
		connecting_point + tail
	], Color("#b8c2b9"))
	tail
