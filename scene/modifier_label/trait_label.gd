extends HBoxContainer


func write(tr8: Actor.Trait) -> void:
	$Icon.texture.region.position.x = tr8 * 8
	$Name.text = Actor.Trait.keys()[tr8]
