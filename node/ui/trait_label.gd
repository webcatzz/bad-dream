extends HBoxContainer


func write(trait_type: Trait.Type) -> void:
	$Text/Name.text = Trait.name(trait_type)
	$Text/Description.text = Trait.describe(trait_type)
	
	$Frame/Icon.region_rect.position = Vector2(
		trait_type % $Frame/Icon.texture.get_width(),
		trait_type / $Frame/Icon.texture.get_width()
	) * 8
