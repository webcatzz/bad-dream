extends SubViewport


func _process(delta: float) -> void:
	get_parent().texture = get_texture()
