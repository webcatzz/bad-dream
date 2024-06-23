class_name DialogueBubble extends DialogueLabel
## Speech bubble label.


var speaker_pos: Vector2
var tail_polygon: PackedVector2Array


func run(string: String) -> void:
	modulate.a = 0
	get_tree().create_tween().tween_property(self, "modulate:a", 1, 0.5)
	await get_tree().create_timer(0.25).timeout
	
	await super(string)
	
	await get_tree().create_tween().tween_property(self, "modulate:a", 0, 0.25).finished
	queue_free()



# internal

func _init() -> void:
	super()
	size.x = 200
	theme_type_variation = &"DialogueBubble"
	material = preload("res://asset/shader/dither_vertex.tres")


func _draw() -> void:
	var center: Vector2 = size / 2
	var camera_pos: Vector2 = get_viewport().get_camera_2d().get_target_position() - get_viewport_rect().size / 2
	
	tail_polygon = [
		(speaker_pos - camera_pos) - (global_position + center) - Vector2(0, 24)
	]
	
	tail_polygon[0] = tail_polygon[0].limit_length(tail_polygon[0].length() - 32)
	
	var tail_angle: float = tail_polygon[0].angle()
	tail_polygon.append(Vector2.from_angle(tail_angle + PI/2) * 8)
	tail_polygon.append(Vector2.from_angle(tail_angle - PI/2) * 8)
	
	tail_polygon = Geometry2D.clip_polygons(tail_polygon, [
		-center, Vector2(center.x, -center.y),
		center, Vector2(-center.x, center.y)
	])[0]
	
	draw_set_transform(size/2)
	draw_colored_polygon(tail_polygon, Color("#b8c2b9"))
