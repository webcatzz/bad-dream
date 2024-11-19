extends HBoxContainer


func write(trait_type: Trait.Type) -> void:
	$Name.text = Trait.name(trait_type)
	$Icon.texture = Trait.icon(trait_type)
