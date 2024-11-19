extends HBoxContainer


func write(condition: Condition) -> void:
	$Name.text = condition.name()
	$Icon.texture = condition.icon()
	$Duration.text = "..." + str(condition.duration_left)
