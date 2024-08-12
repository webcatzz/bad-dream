extends HBoxContainer


func write(condition: Condition) -> void:
	$Name.text = condition.name()
	$Duration.text = "for %s turns" % condition.duration
	
	$Frame/Icon.region_rect.position = Vector2(
		condition.type % $Frame/Icon.texture.get_width(),
		condition.type / $Frame/Icon.texture.get_width()
	) * 8
