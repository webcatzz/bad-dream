extends Label


func _ready():
	var x: int = randi_range(16, 32)
	if randf() > 0.5: x = -x
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position:x", x, 1)
