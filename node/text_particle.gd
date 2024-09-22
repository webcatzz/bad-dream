extends Label


func _ready():
	var x: int = randi_range(16, 32)
	if randf() > 0.5: x = -x
	
	get_tree().create_tween().tween_property(self, "position:x", x, 1)
